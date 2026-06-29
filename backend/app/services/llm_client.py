# backend/app/services/llm_client.py
import os
import json
import httpx
import logging
import asyncio
from app.core.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

GROQ_API_KEY = settings.groq_api_key.strip() if settings.groq_api_key else ""

if not GROQ_API_KEY:
    logger.warning("GROQ_API_KEY not found in environment. LLM evaluation will fail.")

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
    "relevance": 50,
    "coherence": 50,
    "lexical_diversity": 50,
    "coaching_tip": (
        "For your next session: record yourself, then listen back once before viewing "
        "the score. Self-awareness is the first step to improvement."
    ),
    "next_focus": "Reducing filler words",
    "is_fallback": True,
}

COACHING_PROMPT = """[System Core Objective: Plurilingual Speech Evaluator]
You are grading an oral response for an adult speaker. The speaker is explicitly permitted to code-switch fluently between English, Hindi, and Hinglish. 

- Evaluate 'Relevance' based on how well the candidate answers the specific challenge prompt provided below.
- Evaluate 'Coherence' based on the unified conceptual progression of ideas across both languages.
- Grade 'Lexical Diversity' by evaluating the depth, precision, and professional maturity of the vocabulary used across their multilingual repertoire.
- Do not penalize natural code-switching, but evaluate the speaker's ability to maintain a consistent professional register and structural syntax across both languages.

Return ONLY valid JSON, no markdown fences, no preamble, containing strictly the following schema:
{{
  "overall_summary": "2-3 sentences evaluating this answer",
  "strengths": ["specific strength referencing actual content", "specific strength 2"],
  "improvements": ["specific improvement with actionable advice", "specific improvement 2"],
  "relevance": <0-100>,
  "coherence": <0-100>,
  "lexical_diversity": <0-100>,
  "coaching_tip": "the single most impactful thing to practice before the next session",
  "next_focus": "one-line focus area for next session"
}}

CHALLENGE PROMPT ASKED TO CANDIDATE:
{challenge_prompt}

CANDIDATE'S SPOKEN ANSWER (TRANSCRIPT):
{transcript}
"""

async def get_llm_coaching(transcript: str, metrics: dict, challenge_prompt: str = "") -> dict:
    if not challenge_prompt or not challenge_prompt.strip():
        logger.warning("Empty dynamic question. Falling back to avoid hallucinated scores.")
        return FALLBACK_FEEDBACK

    if not transcript or len(transcript.strip()) < 10:
        logger.warning("Transcript too short. Falling back.")
        return {
            **FALLBACK_FEEDBACK,
            "overall_summary": (
                "Recording was too short to evaluate meaningfully. "
                "Aim for at least 30 seconds — a full behavioral answer is typically 90-120 seconds."
            ),
        }

    prompt = COACHING_PROMPT.format(
        challenge_prompt=challenge_prompt,
        transcript=transcript[:3500]
    )

    for attempt in range(3):
        try:
            loop = asyncio.get_event_loop()
            
            def make_request():
                response = httpx.post(
                    "https://api.groq.com/openai/v1/chat/completions",
                    headers={
                        "Authorization": f"Bearer {GROQ_API_KEY}",
                        "Content-Type": "application/json"
                    },
                    json={
                        "model": "llama-3.3-70b-versatile",
                        "messages": [
                            {"role": "system", "content": "You are a professional JSON-only API. You must strictly output valid JSON matching the requested schema and nothing else."},
                            {"role": "user", "content": prompt}
                        ],
                        "temperature": 0.3,
                        "response_format": {"type": "json_object"}
                    },
                    timeout=30.0
                )
                response.raise_for_status()
                return response.json()

            data = await loop.run_in_executor(None, make_request)
            
            raw = data["choices"][0]["message"]["content"].strip()
            
            if raw.startswith("```"):
                parts = raw.split("```")
                raw = parts[1] if len(parts) > 1 else raw
            if raw.lower().startswith("json\n"):
                raw = raw[5:].strip()

            logger.info("Raw LLM output parsed successfully.")
            feedback = json.loads(raw)
            
            # Validate and clamp scores to 0-100
            for field in ("relevance", "coherence", "lexical_diversity"):
                feedback[field] = max(0, min(100, int(feedback.get(field, 50))))

            # Ensure required string fields exist
            feedback.setdefault("strengths", [])
            feedback.setdefault("improvements", [])
            feedback.setdefault("coaching_tip", "")
            feedback.setdefault("next_focus", "")
            feedback.setdefault("overall_summary", FALLBACK_FEEDBACK["overall_summary"])
            feedback["is_fallback"] = False
            
            return feedback

        except Exception as e:
            if "429" in str(e) and attempt < 2:
                logger.warning(f"Groq Rate limit hit (429). Waiting 5 seconds before retry {attempt + 1}...")
                await asyncio.sleep(5)
                continue
            import traceback
            traceback.print_exc()
            logger.error(f"Groq API call failed: {e}. Using fallback.")
            return FALLBACK_FEEDBACK

    return FALLBACK_FEEDBACK
