# backend/app/services/filler_detector.py
# Detects filler words in English AND Hindi/Hinglish transcripts.
# Uses word-level detection with boundary checking to avoid false positives.

import re
import logging

logger = logging.getLogger(__name__)

# ── English primary fillers — always count these ─────────────────────────
ENGLISH_PRIMARY_FILLERS = {
    "um", "uh", "er", "ah",
    "umm", "uhh", "hmm", "hm",
}

# ── Hindi/Hinglish primary fillers — always count these ──────────────────
HINDI_PRIMARY_FILLERS = {
    "matlab",       # "matlab... woh cheez"
    "acha",         # "acha... toh"
    "accha",        # alternate spelling
    "haan",         # "haan... so..."
    "han",          # alternate spelling
    "toh",          # "toh... maine kiya"
    "to",           # alternate spelling (when used as filler)
    "bas",          # "bas... that's it"
    "woh",          # "woh... kya hai na"
    "wo",           # alternate spelling
    "kya",          # "kya... I mean"
    "na",           # "na... you know"
    "arre",         # "arre... listen"
    "are",          # alternate spelling
    "yaar",         # "yaar... it was tough"
    "dekho",        # "dekho... the thing is"
    "samjho",       # "samjho... like"
    "mtlb",         # SMS-style abbreviation of "matlab"
}

# All primary fillers combined
PRIMARY_FILLERS = ENGLISH_PRIMARY_FILLERS | HINDI_PRIMARY_FILLERS

# ── English contextual patterns ──────────────────────────────────────────
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

# ── Hindi/Hinglish contextual patterns ───────────────────────────────────
HINGLISH_CONTEXTUAL_PATTERNS = [
    r"\bkya hai na\b",       # "kya hai na... the thing is"
    r"\bkya bolu\b",         # "kya bolu... what do I say"
    r"\bmera matlab\b",      # "mera matlab... I mean"
    r"\bsamajh\s+rahe\s+ho\b",  # "samajh rahe ho... you understand"
    r"\bsuno\s+na\b",        # "suno na... listen"
    r"\bwaise\s+toh\b",      # "waise toh... actually"
    r"\baise\s+hi\b",        # "aise hi... just like that"
    r"\bthik\s+hai\b",       # "thik hai... okay"
    r"\bbol\s+raha\b",       # "bol raha... I'm saying"
]

ALL_CONTEXTUAL_PATTERNS = CONTEXTUAL_PATTERNS + HINGLISH_CONTEXTUAL_PATTERNS

PATTERN_TO_KEY = {
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
    r"\bkya hai na\b": "kya hai na",
    r"\bkya bolu\b": "kya bolu",
    r"\bmera matlab\b": "mera matlab",
    r"\bsamajh\s+rahe\s+ho\b": "samajh rahe ho",
    r"\bsuno\s+na\b": "suno na",
    r"\bwaise\s+toh\b": "waise toh",
    r"\baise\s+hi\b": "aise hi",
    r"\bthik\s+hai\b": "thik hai",
    r"\bbol\s+raha\b": "bol raha",
}


def detect_fillers(transcript: str, words: list[dict]) -> dict:
    """
    Analyzes the transcript for filler words (English + Hindi/Hinglish).

    Args:
        transcript: Full text string from Whisper
        words: Word-level data from Whisper with timestamps

    Returns:
    {
        "total_count": 12,
        "by_word": {"um": 4, "matlab": 2, "you know": 3},
        "filler_positions": [...]
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
    for pattern in ALL_CONTEXTUAL_PATTERNS:
        matches = re.findall(pattern, text_lower)
        if matches:
            key = PATTERN_TO_KEY.get(pattern, pattern)
            counts[key] = counts.get(key, 0) + len(matches)

    total_count = sum(counts.values())

    logger.debug(f"Filler detection: {total_count} fillers found in {len(words)} words")

    return {
        "total_count": total_count,
        "by_word": counts,
        "filler_positions": filler_positions,
    }
