# backend/app/services/transcriber.py
import logging
from faster_whisper import WhisperModel
from app.core.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

# Module-level model cache — loaded once per process
_model: WhisperModel | None = None


def get_whisper_model() -> WhisperModel:
    """
    Returns the Whisper model, loading it on first call.
    Subsequent calls return the cached instance (no re-load).
    This is called at startup to pre-warm the model.
    """
    global _model
    if _model is None:
        logger.info(f"Loading Whisper model: {settings.whisper_model_size}")
        _model = WhisperModel(
            settings.whisper_model_size,
            device="cpu",
            compute_type="int8",  # Reduces RAM by ~30%, minor accuracy trade-off
        )
        logger.info("Whisper model loaded.")
    return _model


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
    model = get_whisper_model()

    segments, info = model.transcribe(
        wav_path,
        language="en",
        beam_size=5,
        word_timestamps=True,      # Per-word timing — needed for WPM and filler detection
        vad_filter=True,           # Built-in silence filtering
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
                    "word": word.word.strip().lower(),
                    "start": round(word.start, 3),
                    "end": round(word.end, 3),
                    "probability": round(word.probability, 3),
                })

    full_text = " ".join(text_parts).strip()
    word_count = len(full_text.split()) if full_text else 0

    logger.info(
        f"Transcription complete: {word_count} words, "
        f"{info.duration:.1f}s, lang={info.language}"
    )

    return {
        "text": full_text,
        "word_count": word_count,
        "duration_seconds": round(float(info.duration), 2),
        "language": info.language,
        "words": all_words,
    }
