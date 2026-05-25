# backend/Dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies first (cached layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download Whisper model at build time
# This avoids the 30-60s cold start delay on first real request
RUN python -c "\
from faster_whisper import WhisperModel; \
import os; \
model_size = os.environ.get('WHISPER_MODEL_SIZE', 'base'); \
print(f'Downloading Whisper model: {model_size}'); \
WhisperModel(model_size, device='cpu', compute_type='int8'); \
print('Model downloaded successfully.')"

# Copy application code
COPY . .

EXPOSE 8000

# Single worker for free tier (512MB RAM)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
