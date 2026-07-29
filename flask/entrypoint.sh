#!/bin/bash
set -e

echo "Running database migrations..."
uv run python -m flask --app transcribe_server.py db upgrade

echo "Preloading AI models into cache..."
uv run python -c "
import whisper
import ssl
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import time


for attempt in range(3):
    try:
        print(f'Loading models (attempt {attempt+1}/3)...')
        whisper.load_model('small', device='cpu')
        AutoTokenizer.from_pretrained('facebook/nllb-200-distilled-600M')
        AutoModelForSeq2SeqLM.from_pretrained('facebook/nllb-200-distilled-600M')
        from supertonic import TTS
        TTS(auto_download=True)
        print('All models loaded successfully.')
        break
    except Exception as e:
        print(f'Error loading models: {e}')
        if attempt == 2:
            print('Failed to load models after 3 attempts. Proceeding anyway...')
        time.sleep(5)
"

echo "Starting Gunicorn..."
exec gunicorn -c /app/gunicorn.conf.py transcribe_server:app
