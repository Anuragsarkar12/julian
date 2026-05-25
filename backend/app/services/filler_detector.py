# backend/app/services/filler_detector.py
# Detects filler words in the transcript produced by Whisper.
# Uses word-level detection with boundary checking to avoid false positives.
# Example: "like" in "I like this" should NOT count; "like, it was" SHOULD count.

import re
import logging

logger = logging.getLogger(__name__)

# Primary filler words — always count these
PRIMARY_FILLERS = {
    "um", "uh", "er", "ah",
    "umm", "uhh", "hmm", "hm",
}

# Context-dependent fillers — words that are fillers when used as discourse markers
# These are detected via pattern matching, not just presence
CONTEXTUAL_FILLERS = {
    "like",       # "it was like, really hard" — not "I like coding"
    "basically",  # when used as a sentence-starting hedge
    "literally",  # when used for emphasis rather than literalism
    "actually",   # when overused as a hedge
    "right",      # "right?" used as a filler tag question
    "okay",       # "okay so, uh..." as a filler
    "so",         # "so, um, basically..." as a staller
    "you know",   # multi-word filler
    "i mean",     # multi-word filler
    "kind of",    # multi-word filler
    "sort of",    # multi-word filler
}

# Patterns for contextual fillers (must appear at sentence start or before pause)
CONTEXTUAL_PATTERNS = [
    r"\blike\s*,",           # "like," with comma
    r"\bbasically\b",        # basically — nearly always a filler in speech
    r"\bliterally\b",        # literally (usually filler in modern speech)
    r"\bactually\b",         # actually as hedge
    r"\bright\s*\?",         # right? as tag question filler
    r"\bokay\s+so\b",        # "okay so"
    r"\bso\s+um\b",          # "so um"
    r"\byou know\b",         # you know
    r"\bi mean\b",           # i mean
    r"\bkind of\b",          # kind of
    r"\bsort of\b",          # sort of
]


def detect_fillers(transcript: str, words: list[dict]) -> dict:
    """
    Analyzes the transcript for filler words and returns counts.

    Args:
        transcript: Full text string from Whisper
        words: Word-level data from Whisper with timestamps

    Returns:
    {
        "total_count": 12,
        "by_word": {"um": 4, "like": 5, "you know": 3},
        "filler_rate": 2.3,        # fillers per minute (needs duration from caller)
        "filler_positions": [...]  # word start times for visualization
    }
    """
    if not transcript or not transcript.strip():
        return {"total_count": 0, "by_word": {}, "filler_positions": []}

    text_lower = transcript.lower()
    counts: dict[str, int] = {}
    filler_positions: list[float] = []

    # ── 1. Count primary fillers from word list (most accurate) ───────────
    for word_data in words:
        word = word_data.get("word", "").strip().lower().strip(".,!?;:")
        if word in PRIMARY_FILLERS:
            counts[word] = counts.get(word, 0) + 1
            filler_positions.append(word_data.get("start", 0))

    # ── 2. Count contextual fillers via regex on full transcript ──────────
    for pattern in CONTEXTUAL_PATTERNS:
        matches = re.findall(pattern, text_lower)
        if matches:
            # Get the base filler word from the pattern
            key = _clean_pattern_to_key(pattern)
            counts[key] = counts.get(key, 0) + len(matches)

    total_count = sum(counts.values())

    logger.debug(f"Filler detection: {total_count} fillers found in {len(words)} words")

    return {
        "total_count": total_count,
        "by_word": counts,
        "filler_positions": filler_positions,
    }


def _clean_pattern_to_key(pattern: str) -> str:
    """Maps a regex pattern back to a readable key for the by_word dict."""
    mapping = {
        r"\blike\s*,": "like",
        r"\bbasically\b": "basically",
        r"\bliterally\b": "literally",
        r"\bactually\b": "actually",
        r"\bright\s*\?": "right",
        r"\bokay\s+so\b": "okay so",
        r"\bso\s+um\b": "so",
        r"\byou know\b": "you know",
        r"\bi mean\b": "i mean",
        r"\bkind of\b": "kind of",
        r"\bsort of\b": "sort of",
    }
    return mapping.get(pattern, pattern)
