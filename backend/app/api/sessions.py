# backend/app/api/sessions.py
import os
import uuid
import logging
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, BackgroundTasks
from fastapi import status as http_status
from typing import Optional

from app.api.deps import get_current_user
from app.core.config import get_settings
from app.core.database import get_supabase_client
from app.schemas.session import (
    UploadResponse, SessionStatusResponse, SessionResultsResponse,
    MetricsData, ScoresData, FeedbackData, HistoryResponse, HistorySession
)
from app.workers.analysis_pipeline import run_analysis_pipeline

logger = logging.getLogger(__name__)
router = APIRouter()
settings = get_settings()

# Allowed audio MIME types from browser MediaRecorder
ALLOWED_MIME_TYPES = {
    "audio/webm",
    "audio/webm;codecs=opus",
    "audio/ogg",
    "audio/ogg;codecs=opus",
    "audio/mp4",
    "video/webm",   # Some browsers incorrectly label audio-only webm as video
    "video/webm;codecs=vp8,opus",
    "video/webm;codecs=vp9,opus",
}

MAX_FILE_SIZE_BYTES = 50 * 1024 * 1024  # 50MB hard limit


@router.post("/upload", response_model=UploadResponse, status_code=201)
async def upload_session(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    challenge_id: Optional[str] = Form(None),
    question_id: Optional[str] = Form(None),
    current_user: dict = Depends(get_current_user),
):
    """
    Accepts an audio blob from the browser, creates a session record,
    stores the file in Supabase Storage, and kicks off background analysis.
    Returns immediately with a session_id for the frontend to poll.
    """
    user_id = current_user["user_id"]
    db = get_supabase_client()

    # ── Validate file ──────────────────────────────────────────────────────
    content_type = (file.content_type or "").split(";")[0].strip()
    # Be lenient: some browsers send wrong content_type
    audio_data = await file.read()
    if len(audio_data) == 0:
        raise HTTPException(status_code=400, detail="Empty file received.")
    if len(audio_data) > MAX_FILE_SIZE_BYTES:
        raise HTTPException(status_code=413, detail="File too large. Maximum 50MB.")

    # ── Rate limit: max 10 sessions per user per day ───────────────────────
    from datetime import date as date_cls
    today_sessions = (
        db.table("speech_sessions")
        .select("id", count="exact")
        .eq("user_id", user_id)
        .gte("created_at", f"{date_cls.today()}T00:00:00")
        .execute()
    )
    if today_sessions.count and today_sessions.count >= 10:
        raise HTTPException(
            status_code=429,
            detail="Daily limit reached. Maximum 10 sessions per day.",
        )

    # ── Save file to local /tmp ────────────────────────────────────────────
    session_id = str(uuid.uuid4())
    ext = "webm"  # Browser always sends webm regardless of content_type
    local_path = os.path.join(settings.tmp_dir, f"{session_id}.{ext}")
    with open(local_path, "wb") as f:
        f.write(audio_data)

    # ── Upload raw file to Supabase Storage ───────────────────────────────
    storage_path = f"recordings/{user_id}/{session_id}.{ext}"
    try:
        db.storage.from_(settings.supabase_storage_bucket).upload(
            path=storage_path,
            file=audio_data,
            file_options={"content-type": "audio/webm"},
        )
    except Exception as e:
        logger.error(f"Storage upload failed for session {session_id}: {e}")
        # Continue anyway — analysis can proceed from local file

    # ── Create session record ─────────────────────────────────────────────
    session_data = {
        "id": session_id,
        "user_id": user_id,
        "challenge_id": challenge_id,
        "question_id": question_id,
        "status": "processing",
        "storage_path": storage_path,
    }
    db.table("speech_sessions").insert(session_data).execute()

    # ── Queue analysis as background task ─────────────────────────────────
    background_tasks.add_task(
        run_analysis_pipeline,
        session_id=session_id,
        user_id=user_id,
        local_path=local_path,
        question_id=question_id,
    )

    logger.info(f"Session {session_id} created for user {user_id}, analysis queued")
    return UploadResponse(session_id=session_id)


@router.get("/{session_id}/status", response_model=SessionStatusResponse)
async def get_session_status(
    session_id: str,
    current_user: dict = Depends(get_current_user),
):
    """Frontend polls this every 3 seconds while showing 'Analyzing...'"""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    result = (
        db.table("speech_sessions")
        .select("id, status, error_message")
        .eq("id", session_id)
        .eq("user_id", user_id)  # Security: users can only see their own sessions
        .single()
        .execute()
    )
    if not result.data:
        raise HTTPException(status_code=404, detail="Session not found.")

    row = result.data
    return SessionStatusResponse(
        session_id=row["id"],
        status=row["status"],
        error_message=row.get("error_message"),
    )


@router.get("/{session_id}/results", response_model=SessionResultsResponse)
async def get_session_results(
    session_id: str,
    current_user: dict = Depends(get_current_user),
):
    """Returns full analysis results once status == 'completed'."""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    # Fetch session
    session_result = (
        db.table("speech_sessions")
        .select("*, daily_challenges(prompt_text), questions(title, prompt_text)")
        .eq("id", session_id)
        .eq("user_id", user_id)
        .single()
        .execute()
    )
    if not session_result.data:
        raise HTTPException(status_code=404, detail="Session not found.")

    session = session_result.data
    if session["status"] != "completed":
        raise HTTPException(
            status_code=409,
            detail=f"Analysis is {session['status']}. Results not ready yet.",
        )

    # Fetch metrics
    metrics_result = (
        db.table("speech_metrics")
        .select("*")
        .eq("session_id", session_id)
        .single()
        .execute()
    )
    if not metrics_result.data:
        raise HTTPException(status_code=404, detail="Metrics not found.")

    m = metrics_result.data
    gemini = m.get("gemini_feedback") or {}

    # Resolve prompt: try new questions table first, fall back to legacy daily_challenges
    question_data = session.get("questions") or {}
    challenge_data = session.get("daily_challenges") or {}
    challenge_prompt = question_data.get("prompt_text") or challenge_data.get("prompt_text")
    question_title = question_data.get("title")

    return SessionResultsResponse(
        session_id=session_id,
        status="completed",
        transcript=m.get("transcript_text") or "",
        metrics=MetricsData(
            wpm=float(m.get("wpm") or 0),
            word_count=m.get("word_count") or 0,
            duration_seconds=float(session.get("duration_seconds") or 0),
            filler_count=m.get("filler_count") or 0,
            filler_rate=float(m.get("filler_rate") or 0),
            filler_words_found=m.get("filler_words_found") or {},
            pause_count=m.get("pause_count") or 0,
            pause_total_seconds=float(m.get("pause_total_seconds") or 0),
            longest_pause_seconds=float(m.get("longest_pause_seconds") or 0),
            pitch_variance=float(m.get("pitch_variance") or 0),
            energy_variance=float(m.get("energy_variance") or 0),
        ),
        scores=ScoresData(
            delivery_score=m.get("delivery_score") or 0,
            content_score=m.get("content_score") or 0,
            improvement_score=m.get("improvement_score") or 0,
            consistency_score=m.get("consistency_score") or 0,
            total_score=m.get("total_score") or 0,
        ),
        feedback=FeedbackData(
            overall_summary=gemini.get("overall_summary", ""),
            strengths=gemini.get("strengths", []),
            improvements=gemini.get("improvements", []),
            structure_score=gemini.get("structure_score", 5),
            clarity_score=gemini.get("clarity_score", 5),
            engagement_score=gemini.get("engagement_score", 5),
            coaching_tip=gemini.get("coaching_tip", ""),
            next_focus=gemini.get("next_focus", ""),
            is_fallback=gemini.get("is_fallback", False),
        ),
        challenge_prompt=challenge_prompt,
        question_title=question_title,
        created_at=session.get("created_at"),
    )


@router.get("/history/me", response_model=HistoryResponse)
async def get_my_history(
    current_user: dict = Depends(get_current_user),
    limit: int = 20,
):
    """Returns the user's last N completed sessions for the progress chart."""
    db = get_supabase_client()
    user_id = current_user["user_id"]

    result = (
        db.table("speech_metrics")
        .select("session_id, total_score, wpm, filler_count, created_at")
        .eq("user_id", user_id)
        .order("created_at", desc=True)
        .limit(limit)
        .execute()
    )

    sessions = [
        HistorySession(
            session_id=row["session_id"],
            total_score=row.get("total_score") or 0,
            wpm=float(row.get("wpm") or 0),
            filler_count=row.get("filler_count") or 0,
            created_at=row["created_at"],
        )
        for row in (result.data or [])
    ]
    # Reverse so chart shows oldest → newest
    sessions.reverse()
    return HistoryResponse(sessions=sessions)
