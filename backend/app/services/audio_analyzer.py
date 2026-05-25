# backend/app/services/audio_analyzer.py
# Lightweight acoustic feature extraction using only numpy + scipy.
# Replaces librosa to save ~150MB RAM in production.
# All analysis is on 16kHz mono WAV files (output of audio_extractor.py).

import logging
import wave
import struct
import numpy as np
from scipy import signal as scipy_signal

logger = logging.getLogger(__name__)


def _load_wav(wav_path: str) -> tuple[np.ndarray, int]:
    """Load a WAV file into a numpy array. Returns (samples, sample_rate)."""
    with wave.open(wav_path, "rb") as wf:
        sr = wf.getframerate()
        n_frames = wf.getnframes()
        n_channels = wf.getnchannels()
        sample_width = wf.getsampwidth()
        raw = wf.readframes(n_frames)

    # Convert bytes to numpy array
    if sample_width == 2:  # 16-bit PCM (our ffmpeg output)
        dtype = np.int16
    elif sample_width == 4:
        dtype = np.int32
    else:
        dtype = np.int16

    y = np.frombuffer(raw, dtype=dtype).astype(np.float32)

    # If stereo, take first channel
    if n_channels > 1:
        y = y[::n_channels]

    # Normalize to [-1.0, 1.0]
    max_val = float(np.iinfo(dtype).max)
    y = y / max_val

    return y, sr


def analyze_audio(wav_path: str) -> dict:
    """
    Extracts acoustic features from a WAV file.

    Returns:
    {
        "duration_seconds": 62.4,
        "pitch_variance": 34.2,
        "energy_variance": 0.00034,
        "pause_count": 8,
        "pause_total_seconds": 12.3,
        "longest_pause_seconds": 3.1,
    }
    """
    try:
        y, sr = _load_wav(wav_path)
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
    Estimates pitch variance using autocorrelation-based pitch detection.
    Lightweight alternative to librosa.pyin — uses only numpy/scipy.
    """
    try:
        frame_length = 2048
        hop_length = 512
        fmin, fmax = 65.0, 500.0  # Human speech range in Hz

        pitches = []
        for start in range(0, len(y) - frame_length, hop_length):
            frame = y[start : start + frame_length]

            # Skip quiet frames (likely silence)
            if np.max(np.abs(frame)) < 0.01:
                continue

            # Autocorrelation via FFT (fast)
            corr = np.correlate(frame, frame, mode="full")
            corr = corr[len(corr) // 2 :]  # Take positive lags only

            # Find pitch period within human speech range
            min_lag = int(sr / fmax)
            max_lag = int(sr / fmin)
            max_lag = min(max_lag, len(corr) - 1)

            if min_lag >= max_lag:
                continue

            search = corr[min_lag : max_lag + 1]
            if len(search) == 0:
                continue

            peak_idx = np.argmax(search) + min_lag

            # Only accept if autocorrelation is strong (voiced speech)
            if corr[peak_idx] > 0.3 * corr[0] and peak_idx > 0:
                pitch_hz = sr / peak_idx
                pitches.append(pitch_hz)

        if len(pitches) < 10:
            return 0.0

        return float(np.std(pitches))
    except Exception:
        return 0.0


def _compute_energy_variance(y: np.ndarray, sr: int) -> float:
    """Computes RMS energy variance using numpy only."""
    try:
        frame_length = 2048
        hop_length = 512
        rms_values = []

        for start in range(0, len(y) - frame_length, hop_length):
            frame = y[start : start + frame_length]
            rms = np.sqrt(np.mean(frame ** 2))
            rms_values.append(rms)

        if not rms_values:
            return 0.0

        return float(np.std(rms_values))
    except Exception:
        return 0.0


def _detect_pauses(
    y: np.ndarray,
    sr: int,
    min_pause_duration: float = 0.5,
    frame_duration_ms: int = 30,
) -> list[dict]:
    """
    Detects silence gaps using RMS energy thresholding.
    Pure numpy implementation — no librosa dependency.
    """
    frame_length = int(sr * frame_duration_ms / 1000)
    hop_length = frame_length // 2

    # Compute RMS per frame
    rms_values = []
    for start in range(0, len(y) - frame_length, hop_length):
        frame = y[start : start + frame_length]
        rms = np.sqrt(np.mean(frame ** 2))
        rms_values.append(rms)

    if not rms_values:
        return []

    rms_arr = np.array(rms_values)
    if rms_arr.max() == 0:
        return []

    # Dynamic threshold: 10% of mean energy
    threshold = max(float(rms_arr.mean() * 0.10), 1e-5)
    is_silence = rms_arr < threshold

    pauses = []
    in_pause = False
    pause_start = 0.0

    for i, silent in enumerate(is_silence):
        t = float(i * hop_length) / sr
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

    # Handle recording ending in silence
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
