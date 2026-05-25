# backend/app/api/challenges.py
import json
import asyncio
import logging
from fastapi import APIRouter, Depends, HTTPException, Query
from datetime import date
from typing import Optional

import google.generativeai as genai
from app.api.deps import get_current_user
from app.core.config import get_settings
from app.core.database import get_supabase_client
from app.schemas.session import ChallengeResponse

logger = logging.getLogger(__name__)
router = APIRouter()
settings = get_settings()

genai.configure(api_key=settings.gemini_api_key)
_gen_model = genai.GenerativeModel("gemini-2.0-flash")

GENERATE_PROMPT = """Generate a unique behavioral interview question for a software engineer preparing for job interviews.

Category: {category}
Difficulty: {difficulty}

Return ONLY valid JSON, no markdown fences:
{{
  "prompt_text": "The full interview question",
  "tips": ["tip 1 for answering well", "tip 2", "tip 3", "tip 4"]
}}

Rules:
- Make the question specific and realistic — something a real interviewer would ask
- Tips should be actionable and specific to THIS question
- Avoid generic questions like "tell me about yourself"
- For 'technical' category: ask about explaining concepts or architecture decisions
- For 'behavioral': focus on past experiences using STAR format
- For 'impromptu': give a scenario they must respond to on the spot
- For 'persuasion': ask them to convince or pitch something"""

CATEGORIES = ["behavioral", "technical", "impromptu", "persuasion", "storytelling"]
DIFFICULTIES = ["easy", "medium", "hard"]


@router.get("/today", response_model=ChallengeResponse)
async def get_todays_challenge(
    current_user: dict = Depends(get_current_user),
):
    """Returns today's speaking challenge."""
    db = get_supabase_client()
    today = date.today().isoformat()

    try:
        result = (
            db.table("daily_challenges")
            .select("*")
            .eq("challenge_date", today)
            .single()
            .execute()
        )
    except Exception:
        result = None

    if not result or not result.data:
        return ChallengeResponse(
            id="fallback",
            challenge_date=today,
            prompt_text="Tell me about a recent challenge you solved at work or school. What was the problem, what did you do, and what was the outcome?",
            category="behavioral",
            difficulty="medium",
            tips=[
                "Use the STAR format: Situation, Task, Action, Result",
                "Be specific — name the actual problem",
                "Focus on your actions and decisions",
                "End with a concrete outcome or lesson",
            ],
        )

    row = result.data
    return ChallengeResponse(
        id=row["id"],
        challenge_date=row["challenge_date"],
        prompt_text=row["prompt_text"],
        category=row["category"],
        difficulty=row["difficulty"],
        tips=row.get("tips") or [],
    )


@router.get("/random", response_model=ChallengeResponse)
async def get_random_challenge(
    current_user: dict = Depends(get_current_user),
    category: Optional[str] = Query(None, description="behavioral, technical, impromptu, persuasion, storytelling"),
    difficulty: Optional[str] = Query(None, description="easy, medium, hard"),
):
    """Generates a fresh AI-powered interview question on demand."""
    import random

    cat = category if category in CATEGORIES else random.choice(CATEGORIES)
    diff = difficulty if difficulty in DIFFICULTIES else random.choice(DIFFICULTIES)
    today = date.today().isoformat()

    prompt = GENERATE_PROMPT.format(category=cat, difficulty=diff)

    try:
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: _gen_model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    temperature=0.9,  # High creativity for variety
                    max_output_tokens=512,
                ),
            ),
        )

        raw = response.text.strip()
        if raw.startswith("```"):
            parts = raw.split("```")
            raw = parts[1] if len(parts) > 1 else raw
        if raw.lower().startswith("json"):
            raw = raw[4:].strip()

        data = json.loads(raw)

        return ChallengeResponse(
            id="random",
            challenge_date=today,
            prompt_text=data.get("prompt_text", "Tell me about a challenging project you worked on."),
            category=cat,
            difficulty=diff,
            tips=data.get("tips", []),
        )

    except Exception as e:
        logger.error(f"Random question generation failed: {e}")
        # Fallback to a good default
        return ChallengeResponse(
            id="random-fallback",
            challenge_date=today,
            prompt_text="Describe a time you had to make a difficult technical decision with limited information. What was your reasoning process?",
            category=cat,
            difficulty=diff,
            tips=[
                "Frame what information you had vs. what was missing",
                "Explain your decision-making framework",
                "Include the tradeoffs you considered",
                "Share the outcome and what you learned",
            ],
        )
