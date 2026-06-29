# backend/app/services/scoring_engine.py
# Adult Scoring Rubric Engine - Dynamic Pipeline

import logging

logger = logging.getLogger(__name__)

def _normalize(val: float, min_b: float, max_b: float, invert: bool = False) -> float:
    """Computes z-score bounded between 0 and 1."""
    if max_b == min_b:
        return 0.0
    z = (val - min_b) / (max_b - min_b)
    if invert:
        z = (max_b - val) / (max_b - min_b)
    return max(0.0, min(1.0, z))

def _smoothstep(z: float) -> float:
    """Computes S(z) = (3z^2 - 2z^3) * 100.0"""
    return (3 * (z ** 2) - 2 * (z ** 3)) * 100.0

def _clamp(value: int | float, lo: int = 0, hi: int = 100) -> int:
    return max(lo, min(hi, int(value)))

def calculate_all_scores(
    articulation_rate: float,
    mlr: float,
    ptr: float,
    pitch_variance: float,
    energy_variance: float,
    disfluency_density: float,
    gemini_feedback: dict,
) -> dict:
    """
    Computes all score components. Total = Content(50%) + Delivery(50%)
    """
    # 1. Normalization (z)
    z_artic = _normalize(articulation_rate, 3.5, 6.5)
    z_mlr = _normalize(mlr, 6.0, 15.0)
    z_ptr = _normalize(ptr, 70.0, 90.0)
    z_f0 = _normalize(pitch_variance, 30.0, 65.0)
    z_rms = _normalize(energy_variance, 0.01, 0.15)
    z_drate = _normalize(disfluency_density, 0.0, 3.0, invert=True)

    # 2. Smoothstep Activation (S(z))
    s_artic = _smoothstep(z_artic)
    s_mlr = _smoothstep(z_mlr)
    s_ptr = _smoothstep(z_ptr)
    s_f0 = _smoothstep(z_f0)
    s_rms = _smoothstep(z_rms)
    s_drate = _smoothstep(z_drate)

    # 3. Weighted Aggregation for Delivery
    m_temporal = (s_artic + s_mlr + s_ptr) / 3.0
    m_prosody = (s_f0 + s_rms) / 2.0
    m_cognitive = s_drate
    
    delivery_score = _clamp(
        (0.60 * m_temporal) + 
        (0.20 * m_prosody) + 
        (0.20 * m_cognitive)
    )

    # 4. Content Score
    is_fallback = gemini_feedback.get("is_fallback", False)
    if is_fallback:
        content_score = 50
    else:
        relevance = int(gemini_feedback.get("relevance", 50))
        coherence = int(gemini_feedback.get("coherence", 50))
        lexical_diversity = int(gemini_feedback.get("lexical_diversity", 50))
        
        content_score = _clamp(
            (0.40 * relevance) +
            (0.40 * coherence) +
            (0.20 * lexical_diversity)
        )
        
    total_score = _clamp(
        (0.50 * content_score) + 
        (0.50 * delivery_score)
    )
    
    logger.info(
        f"Scores → delivery={delivery_score} content={content_score} total={total_score}"
    )

    return {
        "delivery_score": delivery_score,
        "content_score": content_score,
        "total_score": total_score,
    }
