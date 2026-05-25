# backend/app/services/gemini_client.py
import json
import asyncio
import logging
import google.generativeai as genai
from app.core.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

genai.configure(api_key=settings.gemini_api_key)
_model = genai.GenerativeModel("gemini-2.0-flash")

# Returned when Gemini fails — all downstream code handles is_fallback=True
FALLBACK_FEEDBACK = {
    "overall_summary": (
        "Your speech showed clear effort and commitment to improvement. "
        "Keep building the daily habit — consistency is the most important factor in long-term progress."
    ),
    "strengths": [
        "You completed the challenge — showing up daily is the foundation of improvement",
        "Your delivery demonstrated clear intent",
    ],
    "improvements": [
        "Work on reducing filler words for a more authoritative delivery",
        "Vary your pitch to maintain listener engagement throughout",
    ],
    "structure_score": 5,
    "clarity_score": 5,
    "engagement_score": 5,
    "coaching_tip": (
        "For your next session: record yourself, then listen back once before viewing "
        "the score. Self-awareness is the first step to improvement."
    ),
    "next_focus": "Reducing filler words",
    "is_fallback": True,
}

COACHING_PROMPT = """You are an expert public speaking coach reviewing a speech for a job seeker practicing behavioral interview answers.

Be specific — reference exact words or phrases from the transcript. Avoid generic advice.

CHALLENGE PROMPT: {challenge}

TRANSCRIPT:
{transcript}

DELIVERY METRICS:
- Speaking pace: {wpm} WPM  (ideal range: 110-160 WPM)
- Filler words: {filler_count} total ({filler_rate:.1f} per minute)
- Filler breakdown: {filler_words}
- Pauses: {pause_count} pauses ({pause_secs:.1f}s total silence)
- Duration: {duration:.0f} seconds

INSTRUCTIONS:
Evaluate this as a behavioral interview answer. Score 0-10 on structure (STAR format adherence), 
clarity (easy to follow), and engagement (compelling delivery).

Return ONLY valid JSON, no markdown fences, no preamble:
{{
  "overall_summary": "2-3 sentences evaluating this as a behavioral interview answer",
  "strengths": ["specific strength referencing actual content", "specific strength 2"],
  "improvements": ["specific improvement with actionable advice", "specific improvement 2"],
  "structure_score": <0-10>,
  "clarity_score": <0-10>,
  "engagement_score": <0-10>,
  "coaching_tip": "the single most impactful thing to practice before the next session",
  "next_focus": "one-line focus area for next session"
}}"""


async def get_gemini_coaching(
    transcript: str,
    metrics: dict,
    challenge_prompt: str = "",
) -> dict:
    """
    Calls Gemini 2.5 Flash with the transcript and metrics.
    Returns structured coaching feedback as a dict.
    Falls back gracefully if Gemini is unavailable.
    """
    if not transcript or len(transcript.strip()) < 30:
        return {
            **FALLBACK_FEEDBACK,
            "overall_summary": (
                "Recording was too short to evaluate meaningfully. "
                "Aim for at least 30 seconds — a full behavioral answer is typically 90-120 seconds."
            ),
        }

    prompt = COACHING_PROMPT.format(
        challenge=challenge_prompt or "Open speaking practice",
        transcript=transcript[:3500],  # Truncate very long transcripts
        wpm=round(metrics.get("wpm", 0), 1),
        filler_count=metrics.get("filler_count", 0),
        filler_rate=metrics.get("filler_rate", 0),
        filler_words=metrics.get("filler_words_found", {}),
        pause_count=metrics.get("pause_count", 0),
        pause_secs=metrics.get("pause_total_seconds", 0),
        duration=metrics.get("duration_seconds", 0),
    )

    try:
        # Gemini's SDK is synchronous — run in thread pool to avoid blocking
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: _model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    temperature=0.3,
                    max_output_tokens=1024,
                ),
            ),
        )

        raw = response.text.strip()

        # Strip accidental markdown fences
        if raw.startswith("```"):
            parts = raw.split("```")
            raw = parts[1] if len(parts) > 1 else raw
        if raw.lower().startswith("json"):
            raw = raw[4:].strip()

        feedback = json.loads(raw)

        # Validate and clamp scores
        for field in ("structure_score", "clarity_score", "engagement_score"):
            feedback[field] = max(0, min(10, int(feedback.get(field, 5))))

        # Ensure required fields exist
        feedback.setdefault("strengths", [])
        feedback.setdefault("improvements", [])
        feedback.setdefault("coaching_tip", "")
        feedback.setdefault("next_focus", "")
        feedback["is_fallback"] = False

        logger.info("Gemini coaching feedback received successfully.")
        return feedback

    except json.JSONDecodeError as e:
        logger.warning(f"Gemini returned invalid JSON: {e}. Using fallback.")
        return FALLBACK_FEEDBACK
    except Exception as e:
        logger.error(f"Gemini API call failed: {e}. Using fallback.")
        return FALLBACK_FEEDBACK
