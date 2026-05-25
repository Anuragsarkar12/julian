# backend/app/api/potd.py
import os
import json
import uuid
import asyncio
import logging
import random
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, BackgroundTasks
from datetime import date, timedelta, datetime

import google.generativeai as genai
from app.api.deps import get_current_user
from app.core.config import get_settings
from app.core.database import get_supabase_client
from app.schemas.session import (
    POTDResponse, POTDSubmitResponse, QuestionDetailResponse,
    DailyLeaderboardEntry, DailyLeaderboardResponse,
    POTDArchiveEntry, POTDArchiveResponse,
)
from app.workers.analysis_pipeline import run_analysis_pipeline

logger = logging.getLogger(__name__)
router = APIRouter()
settings = get_settings()

genai.configure(api_key=settings.gemini_api_key)
_gen_model = genai.GenerativeModel("gemini-2.0-flash")

CATEGORIES = [
    "conflict", "leadership", "failure", "achievement", "teamwork",
    "communication", "problem-solving", "adaptability", "initiative", "growth",
]
DIFFICULTIES = ["easy", "medium", "hard"]

GENERATE_PROMPT = """You are a senior technical recruiter at Google who has conducted 2,000+ behavioral interviews.

Generate ONE original behavioral interview question for category: {category}
Difficulty: {difficulty}

Requirements:
- The question must be specific enough that generic answers fail
- It must reveal real competency, not just storytelling ability
- It should be impossible to fake a good answer without real experience
- Phrase it exactly as you would in a real interview at a top tech company

Return ONLY this JSON, no markdown, no preamble:
{{
  "title": "3-5 word title",
  "prompt_text": "The full interview question exactly as asked",
  "category": "{category}",
  "difficulty": "{difficulty}",
  "tips": [
    "Specific tip 1 referencing this exact question",
    "Specific tip 2 referencing this exact question",
    "Specific tip 3 referencing this exact question",
    "Specific tip 4 referencing this exact question"
  ],
  "example_answer": "STAR skeleton: Situation — [what kind of situation fits this]. Task — [what responsibility]. Action — [what specific action reveals the competency]. Result — [what measurable outcome to aim for]."
}}"""


def _get_today_category() -> str:
    """Rotate categories by day of year for variety."""
    day_of_year = date.today().timetuple().tm_yday
    return CATEGORIES[day_of_year % len(CATEGORIES)]


def _get_today_difficulty() -> str:
    """Cycle difficulty: easy → medium → hard."""
    day_of_year = date.today().timetuple().tm_yday
    return DIFFICULTIES[day_of_year % len(DIFFICULTIES)]


async def _generate_question_via_gemini(category: str, difficulty: str) -> dict | None:
    """Generate a new question using Gemini. Returns None on failure."""
    prompt = GENERATE_PROMPT.format(category=category, difficulty=difficulty)
    try:
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: _gen_model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    temperature=0.9,
                    max_output_tokens=1024,
                ),
            ),
        )
        raw = response.text.strip()
        if raw.startswith("```"):
            parts = raw.split("```")
            raw = parts[1] if len(parts) > 1 else raw
        if raw.lower().startswith("json"):
            raw = raw[4:].strip()
        return json.loads(raw)
    except Exception as e:
        logger.error(f"Gemini question generation failed: {e}")
        return None


async def _ensure_potd_exists(db, user_id: str) -> dict:
    """
    Lazy initialization: if no POTD for today, create one.
    1. Try Gemini generation
    2. Fall back to eligible bank question
    """
    today = date.today().isoformat()

    # Check if POTD already exists
    try:
        existing = (
            db.table("potd")
            .select("*, questions(*)")
            .eq("potd_date", today)
            .maybe_single()
            .execute()
        )
        if existing and existing.data:
            return existing.data
    except Exception:
        pass

    # Need to create today's POTD
    category = _get_today_category()
    difficulty = _get_today_difficulty()

    # Try Gemini first
    generated = await _generate_question_via_gemini(category, difficulty)
    question_id = None

    if generated:
        # Generate a slug
        title = generated.get("title", "Generated Question")
        slug = f"potd-{today}-{title.lower().replace(' ', '-')[:30]}"

        try:
            q_result = db.table("questions").insert({
                "slug": slug,
                "title": title,
                "prompt_text": generated.get("prompt_text", ""),
                "category": generated.get("category", category),
                "difficulty": generated.get("difficulty", difficulty),
                "tips": generated.get("tips", []),
                "example_answer": generated.get("example_answer"),
                "is_potd_eligible": True,
                "added_date": today,
            }).execute()
            if q_result.data:
                question_id = q_result.data[0]["id"]
        except Exception as e:
            logger.error(f"Failed to insert generated question: {e}")

    # Fallback: pick from existing bank
    if not question_id:
        cutoff = (date.today() - timedelta(days=60)).isoformat()
        try:
            # Get questions not used as POTD in last 60 days
            bank_result = (
                db.table("questions")
                .select("id")
                .eq("is_potd_eligible", True)
                .eq("category", category)
                .order("created_at")
                .limit(20)
                .execute()
            )
            candidates = bank_result.data or []

            if not candidates:
                # Try any category
                bank_result = (
                    db.table("questions")
                    .select("id")
                    .eq("is_potd_eligible", True)
                    .order("created_at")
                    .limit(20)
                    .execute()
                )
                candidates = bank_result.data or []

            # Filter out recent POTDs
            recent_potd = (
                db.table("potd")
                .select("question_id")
                .gte("potd_date", cutoff)
                .execute()
            )
            recent_ids = {p["question_id"] for p in (recent_potd.data or [])}
            candidates = [c for c in candidates if c["id"] not in recent_ids]

            if candidates:
                question_id = random.choice(candidates)["id"]
            elif bank_result.data:
                # All used recently; just pick one
                question_id = random.choice(bank_result.data)["id"]
        except Exception as e:
            logger.error(f"Failed to select bank question for POTD: {e}")

    if not question_id:
        raise HTTPException(status_code=500, detail="Could not create POTD. No questions available.")

    # Create POTD record
    potd_result = (
        db.table("potd")
        .insert({"question_id": question_id, "potd_date": today})
        .execute()
    )

    # Fetch the full record
    full = (
        db.table("potd")
        .select("*, questions(*)")
        .eq("potd_date", today)
        .single()
        .execute()
    )
    return full.data


@router.get("/today", response_model=POTDResponse)
async def get_todays_potd(
    current_user: dict = Depends(get_current_user),
):
    """Returns today's POTD question + user submission status."""
    db = get_supabase_client()
    user_id = current_user["user_id"]
    today = date.today().isoformat()

    potd_data = await _ensure_potd_exists(db, user_id)
    question = potd_data.get("questions", {})

    # Check user submission
    try:
        sub_result = (
            db.table("daily_leaderboard")
            .select("score, session_id")
            .eq("user_id", user_id)
            .eq("potd_date", today)
            .maybe_single()
            .execute()
        )
        submission = sub_result.data if sub_result else None
    except Exception:
        submission = None

    # User attempts on this question
    try:
        attempt_result = (
            db.table("user_question_attempts")
            .select("attempts, best_score")
            .eq("user_id", user_id)
            .eq("question_id", question.get("id", ""))
            .maybe_single()
            .execute()
        )
        attempt = attempt_result.data if attempt_result else None
    except Exception:
        attempt = None

    return POTDResponse(
        potd_id=potd_data["id"],
        potd_date=potd_data["potd_date"],
        question=QuestionDetailResponse(
            id=question.get("id", ""),
            slug=question.get("slug", ""),
            title=question.get("title", ""),
            prompt_text=question.get("prompt_text", ""),
            category=question.get("category", ""),
            difficulty=question.get("difficulty", ""),
            tips=question.get("tips") or [],
            example_answer=question.get("example_answer"),
            times_attempted=question.get("times_attempted", 0),
            avg_score=float(question.get("avg_score", 0)),
            user_attempts=attempt["attempts"] if attempt else 0,
            user_best_score=attempt["best_score"] if attempt else None,
        ),
        user_submitted=submission is not None,
        user_score=submission["score"] if submission else None,
        user_session_id=submission["session_id"] if submission else None,
    )


@router.post("/submit", response_model=POTDSubmitResponse, status_code=201)
async def submit_potd(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    current_user: dict = Depends(get_current_user),
):
    """Submit audio for today's POTD. First submission counts for leaderboard."""
    db = get_supabase_client()
    user_id = current_user["user_id"]
    today = date.today().isoformat()

    # Get today's POTD
    potd_data = await _ensure_potd_exists(db, user_id)
    question_id = potd_data["questions"]["id"] if potd_data.get("questions") else potd_data.get("question_id")

    if not question_id:
        raise HTTPException(status_code=500, detail="POTD question not found.")

    # Read and validate file
    audio_data = await file.read()
    if len(audio_data) == 0:
        raise HTTPException(status_code=400, detail="Empty file received.")
    if len(audio_data) > 50 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="File too large. Maximum 50MB.")

    # Save to local temp
    session_id = str(uuid.uuid4())
    local_path = os.path.join(settings.tmp_dir, f"{session_id}.webm")
    with open(local_path, "wb") as f:
        f.write(audio_data)

    # Upload to storage
    storage_path = f"recordings/{user_id}/{session_id}.webm"
    try:
        db.storage.from_(settings.supabase_storage_bucket).upload(
            path=storage_path,
            file=audio_data,
            file_options={"content-type": "audio/webm"},
        )
    except Exception as e:
        logger.error(f"Storage upload failed for POTD session {session_id}: {e}")

    # Create session record
    db.table("speech_sessions").insert({
        "id": session_id,
        "user_id": user_id,
        "question_id": question_id,
        "status": "processing",
        "storage_path": storage_path,
    }).execute()

    # Queue analysis with POTD flag
    background_tasks.add_task(
        run_analysis_pipeline,
        session_id=session_id,
        user_id=user_id,
        local_path=local_path,
        is_potd=True,
        question_id=question_id,
    )

    return POTDSubmitResponse(session_id=session_id)


@router.get("/leaderboard", response_model=DailyLeaderboardResponse)
async def get_potd_leaderboard(
    current_user: dict = Depends(get_current_user),
    date_str: str = None,
):
    """Get the daily leaderboard for a specific date (defaults to today)."""
    db = get_supabase_client()
    user_id = current_user["user_id"]
    target_date = date_str or date.today().isoformat()

    # Get question title for this date
    question_title = None
    try:
        potd_result = (
            db.table("potd")
            .select("questions(title)")
            .eq("potd_date", target_date)
            .maybe_single()
            .execute()
        )
        if potd_result and potd_result.data:
            question_title = (potd_result.data.get("questions") or {}).get("title")
    except Exception:
        pass

    # Fetch leaderboard entries
    result = (
        db.table("daily_leaderboard")
        .select("*, users(full_name, avatar_url)")
        .eq("potd_date", target_date)
        .order("score", desc=True)
        .order("submitted_at")
        .limit(100)
        .execute()
    )

    entries = []
    for rank, row in enumerate(result.data or [], start=1):
        user_info = row.get("users") or {}
        entries.append(DailyLeaderboardEntry(
            rank=rank,
            user_id=row["user_id"],
            full_name=user_info.get("full_name"),
            avatar_url=user_info.get("avatar_url"),
            score=row["score"],
            submitted_at=row.get("submitted_at"),
            is_current_user=(row["user_id"] == user_id),
        ))

    return DailyLeaderboardResponse(
        date=target_date,
        question_title=question_title,
        total_submissions=len(entries),
        entries=entries,
    )


@router.get("/archive", response_model=POTDArchiveResponse)
async def get_potd_archive(
    current_user: dict = Depends(get_current_user),
    limit: int = 7,
):
    """Returns the last N POTDs with question details and top scorer."""
    db = get_supabase_client()

    result = (
        db.table("potd")
        .select("*, questions(id, title, category, difficulty)")
        .order("potd_date", desc=True)
        .limit(limit)
        .execute()
    )

    entries = []
    for row in (result.data or []):
        q = row.get("questions") or {}

        # Get top scorer for this date
        top_score = None
        top_user_name = None
        try:
            lb = (
                db.table("daily_leaderboard")
                .select("score, users(full_name)")
                .eq("potd_date", row["potd_date"])
                .order("score", desc=True)
                .limit(1)
                .execute()
            )
            if lb.data:
                top_score = lb.data[0].get("score")
                top_user_name = (lb.data[0].get("users") or {}).get("full_name")
        except Exception:
            pass

        entries.append(POTDArchiveEntry(
            potd_date=row["potd_date"],
            question_title=q.get("title", ""),
            question_category=q.get("category", ""),
            question_difficulty=q.get("difficulty", ""),
            question_id=q.get("id", ""),
            top_score=top_score,
            top_user_name=top_user_name,
        ))

    return POTDArchiveResponse(entries=entries)
