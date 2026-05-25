# backend/app/services/audio_analyzer.py
# Uses librosa for acoustic feature extraction.
# All analysis is on 16kHz mono WAV files (output of audio_extractor.py).

import logging
import numpy as np
import librosa

logger = logging.getLogger(__name__)


def analyze_audio(wav_path: str) -> dict:
    """
    Extracts acoustic features from a WAV file.

    Returns:
    {
        "duration_seconds": 62.4,
        "pitch_variance": 34.2,       # Hz std dev of detected pitch
        "energy_variance": 0.00034,   # RMS energy std dev
        "pause_count": 8,             # Pauses >= 0.5 seconds
        "pause_total_seconds": 12.3,
        "longest_pause_seconds": 3.1,
    }
    """
    try:
        # Load audio at 16kHz mono (should already be this from ffmpeg)
        y, sr = librosa.load(wav_path, sr=16000, mono=True)
        duration = float(len(y) / sr)

        pitch_variance = _compute_pitch_variance(y, sr)
        energy_variance = _compute_energy_variance(y, sr)
        pauses = _detect_pauses(y, sr)

        result = {
            "duration_seconds": round(duration, 2),
            "pitch_variance": round(pitch_variance, 4),
            "energy_variance": round(energy_variance, 8),
            "pause_count": len(pauses),
            "pause_total_seconds": round(sum(p["duration"] for p in pauses), 2),
            "longest_pause_seconds": round(
                max((p["duration"] for p in pauses), default=0.0), 2
            ),
        }

        logger.info(
            f"Audio analysis: {duration:.1f}s, pitch_var={pitch_variance:.1f}, "
            f"pauses={len(pauses)}"
        )
        return result

    except Exception as e:
        logger.error(f"Audio analysis failed for {wav_path}: {e}", exc_info=True)
        # Return safe defaults rather than crashing the pipeline
        return {
            "duration_seconds": 0.0,
            "pitch_variance": 0.0,
            "energy_variance": 0.0,
            "pause_count": 0,
            "pause_total_seconds": 0.0,
            "longest_pause_seconds": 0.0,
        }


def _compute_pitch_variance(y: np.ndarray, sr: int) -> float:
    """
    Computes pitch variance using librosa's pyin algorithm.
    Higher variance = more expressive, varied intonation.
    Low variance = monotone delivery.

    Returns standard deviation of detected pitch in Hz.
    """
    try:
        # pyin gives more accurate pitch than piptrack for speech
        f0, voiced_flag, voiced_probs = librosa.pyin(
            y,
            fmin=librosa.note_to_hz("C2"),   # ~65 Hz — lowest human speech
            fmax=librosa.note_to_hz("C7"),   # ~2093 Hz — highest human speech
            sr=sr,
            frame_length=2048,
        )
        # Only use voiced frames (where speech is actually detected)
        voiced_f0 = f0[voiced_flag]
        if len(voiced_f0) < 10:
            return 0.0
        return float(np.std(voiced_f0))
    except Exception:
        return 0.0


def _compute_energy_variance(y: np.ndarray, sr: int) -> float:
    """
    Computes RMS energy variance across the recording.
    Used to detect dynamic range in delivery.
    """
    try:
        rms = librosa.feature.rms(y=y, frame_length=2048, hop_length=512)[0]
        return float(np.std(rms))
    except Exception:
        return 0.0


def _detect_pauses(
    y: np.ndarray,
    sr: int,
    min_pause_duration: float = 0.5,  # Minimum 500ms to count as a pause
    frame_duration_ms: int = 30,
) -> list[dict]:
    """
    Detects silence gaps (pauses) using RMS energy thresholding.

    A frame is considered silence if its RMS energy is below a
    dynamic threshold set at 10% of the audio's mean energy.

    Returns list of: {"start": float, "end": float, "duration": float}
    """
    frame_length = int(sr * frame_duration_ms / 1000)
    hop_length = frame_length // 2

    rms = librosa.feature.rms(y=y, frame_length=frame_length, hop_length=hop_length)[0]

    if len(rms) == 0 or rms.max() == 0:
        return []

    # Dynamic threshold: 10% of mean energy (adapts to recording volume)
    threshold = max(rms.mean() * 0.10, 1e-5)
    is_silence = rms < threshold

    pauses = []
    in_pause = False
    pause_start = 0.0

    for i, silent in enumerate(is_silence):
        t = float(librosa.frames_to_time(i, sr=sr, hop_length=hop_length))
        if silent and not in_pause:
            in_pause = True
            pause_start = t
        elif not silent and in_pause:
            duration = t - pause_start
            if duration >= min_pause_duration:
                pauses.append({
                    "start": round(pause_start, 3),
                    "end": round(t, 3),
                    "duration": round(duration, 3),
                })
            in_pause = False

    # Handle case where recording ends while still in a pause
    if in_pause:
        final_t = float(len(y) / sr)
        duration = final_t - pause_start
        if duration >= min_pause_duration:
            pauses.append({
                "start": round(pause_start, 3),
                "end": round(final_t, 3),
                "duration": round(duration, 3),
            })

    return pauses
