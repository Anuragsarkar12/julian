# backend/app/services/transcriber.py
# Uses Groq's free Whisper API for fast, accurate transcription.
# Local faster-whisper is ONLY imported if GROQ_API_KEY is not set,
# keeping ~250MB of RAM free in production.

import os
import logging
import httpx
from app.core.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

GROQ_API_KEY = settings.groq_api_key.strip() if settings.groq_api_key else ""
USE_GROQ = bool(GROQ_API_KEY)


def preload_model():
    """Called at startup. With Groq, this is a no-op (no model to load)."""
    if USE_GROQ:
        logger.info("Using Groq Whisper API — no local model to load (saving ~250MB RAM).")
    else:
        logger.info("GROQ_API_KEY not set — loading local Whisper model.")
        _get_local_model()


def transcribe_audio(wav_path: str) -> dict:
    """
    Transcribes a WAV file and returns full transcript with word timestamps.

    Returns:
    {
        "text": "full transcript as a string",
        "word_count": 142,
        "duration_seconds": 65.3,
        "language": "en",
        "words": [{"word": "hello", "start": 0.12, "end": 0.45, "probability": 0.98}, ...]
    }
    """
    if USE_GROQ:
        return _transcribe_groq(wav_path)
    else:
        return _transcribe_local(wav_path)


def _transcribe_groq(wav_path: str) -> dict:
    """Transcribe using Groq's free Whisper API (~2-5 seconds for any audio)."""
    try:
        with open(wav_path, "rb") as f:
            response = httpx.post(
                "https://api.groq.com/openai/v1/audio/transcriptions",
                headers={"Authorization": f"Bearer {GROQ_API_KEY}"},
                files={"file": (os.path.basename(wav_path), f, "audio/wav")},
                data={
                    "model": "whisper-large-v3",
                    "response_format": "verbose_json",
                    "timestamp_granularities[]": "word",
                    # No language forced — auto-detects English, Hindi, Hinglish
                },
                timeout=60.0,
            )

        if response.status_code != 200:
            logger.error(f"Groq API error {response.status_code}: {response.text}")
            return _transcribe_local(wav_path)

        data = response.json()
        full_text = data.get("text", "").strip()
        duration = float(data.get("duration", 0))
        word_count = len(full_text.split()) if full_text else 0

        all_words = []
        for word_data in data.get("words", []):
            all_words.append({
                "word": word_data.get("word", "").strip().lower().strip(".,!?;:"),
                "start": round(float(word_data.get("start", 0)), 3),
                "end": round(float(word_data.get("end", 0)), 3),
                "probability": 0.95,
            })

        detected_lang = data.get("language", "en")
        logger.info(
            f"Groq transcription complete: {word_count} words, "
            f"{duration:.1f}s, lang={detected_lang}, "
            f"response in ~{response.elapsed.total_seconds():.1f}s"
        )

        return {
            "text": full_text,
            "word_count": word_count,
            "duration_seconds": round(duration, 2),
            "language": detected_lang,
            "words": all_words,
        }

    except Exception as e:
        logger.error(f"Groq transcription failed: {e}. Falling back to local.")
        return _transcribe_local(wav_path)


# ── Local Whisper fallback (only loaded if GROQ_API_KEY not set) ─────────

_local_model = None


def _get_local_model():
    """Lazy-load local Whisper model only when absolutely needed."""
    global _local_model
    if _local_model is None:
        # Import only when needed — this import alone costs ~200MB RAM
        from faster_whisper import WhisperModel
        logger.info(f"Loading local Whisper model: {settings.whisper_model_size}")
        _local_model = WhisperModel(
            settings.whisper_model_size,
            device="cpu",
            compute_type="int8",
        )
        logger.info("Local Whisper model loaded.")
    return _local_model


def _transcribe_local(wav_path: str) -> dict:
    """Transcribe using local faster-whisper (slow on free-tier CPUs)."""
    model = _get_local_model()

    segments, info = model.transcribe(
        wav_path,
        # No language forced — auto-detects English, Hindi, Hinglish
        beam_size=5,
        word_timestamps=True,
        vad_filter=True,
        vad_parameters={
            "min_silence_duration_ms": 500,
            "threshold": 0.5,
        },
    )

    all_words = []
    text_parts = []

    for segment in segments:
        text_parts.append(segment.text.strip())
        if segment.words:
            for word in segment.words:
                all_words.append({
                    "word": word.word.strip().lower().strip(".,!?;:"),
                    "start": round(word.start, 3),
                    "end": round(word.end, 3),
                    "probability": round(word.probability, 3),
                })

    full_text = " ".join(text_parts).strip()
    word_count = len(full_text.split()) if full_text else 0

    logger.info(
        f"Local transcription complete: {word_count} words, "
        f"{info.duration:.1f}s, lang={info.language}"
    )

    return {
        "text": full_text,
        "word_count": word_count,
        "duration_seconds": round(float(info.duration), 2),
        "language": info.language,
        "words": all_words,
    }
