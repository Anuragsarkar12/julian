# backend/app/services/audio_extractor.py
import subprocess
import os
import logging

logger = logging.getLogger(__name__)


def extract_audio_to_wav(input_path: str, output_path: str) -> str:
    """
    Converts any audio/video file to WAV format suitable for speech analysis.

    Output spec:
    - 16,000 Hz sample rate  (Whisper training spec)
    - Mono (1 channel)       (speech analysis doesn't need stereo)
    - 16-bit PCM             (uncompressed, best analysis quality)

    Returns output_path on success, raises RuntimeError on failure.
    """
    cmd = [
        "ffmpeg",
        "-i", input_path,       # Input (any format the browser sent)
        "-vn",                  # Discard video stream if present
        "-acodec", "pcm_s16le", # Output codec: 16-bit signed PCM little-endian
        "-ar", "16000",         # Sample rate: 16kHz
        "-ac", "1",             # Channels: 1 (mono)
        "-y",                   # Overwrite output file if exists
        output_path,
    ]

    logger.debug(f"Running ffmpeg: {' '.join(cmd)}")

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=120,  # 2 minute timeout for very long recordings
    )

    if result.returncode != 0:
        logger.error(f"ffmpeg stderr: {result.stderr}")
        raise RuntimeError(f"Audio conversion failed: {result.stderr[-500:]}")

    if not os.path.exists(output_path) or os.path.getsize(output_path) == 0:
        raise RuntimeError(f"ffmpeg produced no output at {output_path}")

    size_kb = os.path.getsize(output_path) / 1024
    logger.info(f"Audio converted: {input_path} → {output_path} ({size_kb:.0f}KB)")
    return output_path
