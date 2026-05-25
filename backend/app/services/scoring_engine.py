# backend/app/services/scoring_engine.py
# All scoring is deterministic: same inputs always produce the same outputs.
# Gemini feedback augments the content score but does NOT replace it.

import logging

logger = logging.getLogger(__name__)


def calculate_all_scores(
    wpm: float,
    filler_count: int,
    filler_rate: float,
    pause_count: int,
    pause_total_seconds: float,
    pitch_variance: float,
    word_count: int,
    duration_seconds: float,
    gemini_feedback: dict,
    previous_total_score: int | None = None,
    current_streak: int = 0,
) -> dict:
    """
    Computes all four score components and total score.

    Total = Content(45%) + Delivery(30%) + Improvement(15%) + Consistency(10%)
    Content is king — what you say matters more than how fast you say it.
    All scores: integers 0-100.
    """
    delivery_score = _compute_delivery_score(
        wpm, filler_rate, pause_count, duration_seconds, pitch_variance
    )
    content_score = _compute_content_score(
        word_count, duration_seconds, gemini_feedback
    )
    improvement_score = _compute_improvement_score(
        delivery_score, content_score, previous_total_score
    )
    consistency_score = _compute_consistency_score(current_streak)

    total_score = int(
        content_score * 0.45
        + delivery_score * 0.30
        + improvement_score * 0.15
        + consistency_score * 0.10
    )
    total_score = _clamp(total_score)

    logger.info(
        f"Scores → delivery={delivery_score} content={content_score} "
        f"improvement={improvement_score} consistency={consistency_score} "
        f"total={total_score}"
    )

    return {
        "delivery_score": delivery_score,
        "content_score": content_score,
        "improvement_score": improvement_score,
        "consistency_score": consistency_score,
        "total_score": total_score,
    }


def _compute_delivery_score(
    wpm: float,
    filler_rate: float,
    pause_count: int,
    duration_seconds: float,
    pitch_variance: float,
) -> int:
    """
    Delivery = WPM(35%) + Filler(35%) + Pause(15%) + Pitch(15%)
    """
    wpm_score    = _score_wpm(wpm)
    filler_score = _score_filler_rate(filler_rate)
    pause_score  = _score_pauses(pause_count, duration_seconds)
    pitch_score  = _score_pitch_variance(pitch_variance)

    delivery = int(
        wpm_score    * 0.35
        + filler_score * 0.35
        + pause_score  * 0.15
        + pitch_score  * 0.15
    )
    return _clamp(delivery)


def _compute_content_score(
    word_count: int,
    duration_seconds: float,
    gemini_feedback: dict,
) -> int:
    """
    Content score combines:
    - Deterministic baseline (30% weight): derived from word count and duration
    - Gemini augmentation (70% weight): structure, clarity, engagement, relevance

    If Gemini fails (is_fallback=True), full weight goes to deterministic baseline
    with a cap at 60 (you can't score high on content without AI evaluation).
    """
    # Deterministic baseline: penalize very short or very long responses
    baseline = _score_response_quality(word_count, duration_seconds)

    is_fallback = gemini_feedback.get("is_fallback", False)
    if is_fallback:
        return _clamp(min(baseline, 60))  # Cap at 60 without AI evaluation

    # Gemini component: four 0-10 scores, weighted average, normalized to 0-100
    structure  = int(gemini_feedback.get("structure_score", 5)) * 10
    clarity    = int(gemini_feedback.get("clarity_score", 5)) * 10
    engagement = int(gemini_feedback.get("engagement_score", 5)) * 10
    relevance  = int(gemini_feedback.get("relevance_score", 5)) * 10

    # Relevance is weighted heaviest — off-topic answers should tank the score
    gemini_component = _clamp(int(
        relevance  * 0.35
        + structure * 0.25
        + clarity   * 0.25
        + engagement * 0.15
    ))

    content = int(baseline * 0.30 + gemini_component * 0.70)
    return _clamp(content)


def _compute_improvement_score(
    delivery_score: int,
    content_score: int,
    previous_total_score: int | None,
) -> int:
    """
    Compares this session's score to the previous session.
    First-ever session gets 70 (baseline encouragement).
    Improvement of +10 points = score of 90+.
    """
    if previous_total_score is None:
        return 70  # First session: neutral baseline

    current_avg = int((delivery_score + content_score) / 2)
    delta = current_avg - previous_total_score
    # delta of +10 → score of 90, delta of -10 → score of 50, delta of 0 → 70
    improvement = int(70 + delta * 2)
    return _clamp(improvement)


def _compute_consistency_score(current_streak: int) -> int:
    """
    Consistency = streak-based.
    0 days: 40, 3 days: 60, 7 days: 80, 14 days: 90, 30+ days: 100
    """
    if current_streak <= 0:   return 40
    elif current_streak <= 2: return 50
    elif current_streak <= 6: return 60 + (current_streak - 3) * 5
    elif current_streak <= 13: return 75 + (current_streak - 7) * 2
    elif current_streak <= 29: return 90 + (current_streak - 14) // 4
    else: return 100


# ── Individual metric scorers ───────────────────────────────────────────────

def _score_wpm(wpm: float) -> float:
    """Ideal: 110-160 WPM (TED Talk average is ~130 WPM)."""
    if wpm <= 0:       return 10.0
    elif wpm < 80:     return 20.0 + (wpm / 80.0) * 30.0
    elif wpm < 110:    return 70.0 + ((wpm - 80.0) / 30.0) * 15.0
    elif wpm <= 160:   return 100.0
    elif wpm <= 185:   return 100.0 - ((wpm - 160.0) / 25.0) * 25.0
    else:              return max(20.0, 75.0 - ((wpm - 185.0) / 40.0) * 30.0)


def _score_filler_rate(filler_rate: float) -> float:
    """Fillers per minute. Professional target < 1/min."""
    if filler_rate <= 0:   return 100.0
    elif filler_rate <= 1: return 100.0 - filler_rate * 10.0
    elif filler_rate <= 3: return 90.0 - ((filler_rate - 1.0) / 2.0) * 20.0
    elif filler_rate <= 5: return 70.0 - ((filler_rate - 3.0) / 2.0) * 20.0
    elif filler_rate <= 8: return 50.0 - ((filler_rate - 5.0) / 3.0) * 20.0
    else:                  return max(5.0, 30.0 - (filler_rate - 8.0) * 3.0)


def _score_pauses(pause_count: int, duration_seconds: float) -> float:
    """
    Strategic pauses are good — they aid comprehension.
    Too many = lack of fluency. Too few = no breathing room.
    Target: 1-4 deliberate pauses per minute.
    """
    if duration_seconds <= 0: return 50.0
    ppm = (pause_count / duration_seconds) * 60.0  # pauses per minute
    if ppm <= 0.5:   return 60.0
    elif ppm <= 1.0: return 70.0 + ppm * 20.0
    elif ppm <= 4.0: return 100.0
    elif ppm <= 6.0: return 100.0 - ((ppm - 4.0) / 2.0) * 15.0
    elif ppm <= 9.0: return 85.0 - ((ppm - 6.0) / 3.0) * 25.0
    else:            return max(20.0, 60.0 - (ppm - 9.0) * 5.0)


def _score_pitch_variance(pitch_variance: float) -> float:
    """
    Higher variance = more expressive delivery.
    Near zero = robotic monotone. Extremely high = chaotic.
    """
    if pitch_variance <= 0:    return 30.0
    elif pitch_variance < 10:  return 30.0 + (pitch_variance / 10.0) * 20.0
    elif pitch_variance < 20:  return 50.0 + ((pitch_variance - 10.0) / 10.0) * 20.0
    elif pitch_variance < 40:  return 70.0 + ((pitch_variance - 20.0) / 20.0) * 20.0
    elif pitch_variance <= 65: return 90.0 + ((pitch_variance - 40.0) / 25.0) * 5.0
    else:                      return 95.0


def _score_response_quality(word_count: int, duration_seconds: float) -> int:
    """
    Deterministic baseline for content quality.
    Penalizes: too short, too long without substance, speaking without saying much.
    """
    if duration_seconds < 20 or word_count < 30:
        return 30  # Too short to evaluate properly

    minutes = duration_seconds / 60.0
    words_per_minute = word_count / minutes if minutes > 0 else 0

    # Penalize if word count is very low relative to duration (lots of silence/padding)
    if words_per_minute < 60:   return 45
    elif words_per_minute < 90: return 60
    elif words_per_minute < 130: return 75
    elif words_per_minute <= 170: return 85
    else: return 80  # Very dense — may be hard to follow


def _clamp(value: int | float, lo: int = 0, hi: int = 100) -> int:
    return max(lo, min(hi, int(value)))
