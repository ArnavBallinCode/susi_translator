#!/bin/bash
set -e

echo "Running database migrations..."
uv run python -m flask --app transcribe_server.py db upgrade

echo "Preloading AI models into cache..."
uv run python -c "
import whisper
import ssl
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

ssl._create_default_https_context = ssl._create_unverified_context
print('Loading Whisper...')
whisper.load_model('small', device='cpu')
print('Loading NLLB-200...')
AutoTokenizer.from_pretrained('facebook/nllb-200-distilled-600M')
AutoModelForSeq2SeqLM.from_pretrained('facebook/nllb-200-distilled-600M')
print('Loading Supertonic TTS...')
from supertonic import TTS
TTS(auto_download=True)
print('All models loaded.')
"

echo "Starting Gunicorn..."
exec gunicorn -c /app/gunicorn.conf.py transcribe_server:app
