#!/bin/bash
set -e

export UV_LINK_MODE=copy

echo "Running database migrations..."
TRANSCRIBE_AUTOSTART_WORKER=false uv run python -m flask --app transcribe_server.py db upgrade

echo "Preloading AI models into cache..."
uv run python -c "
from faster_whisper import WhisperModel
from transformers import AutoTokenizer
from supertonic import TTS
import time

for attempt in range(3):
    try:
        print(f'Loading models (attempt {attempt+1}/3)...')

        # Faster Whisper (CTranslate2-accelerated) — NOT openai-whisper
        WhisperModel('small', device='cpu', compute_type='int8')
        print('  [OK] Faster Whisper loaded')

        # NLLB-200 translation model (converts to int8 CTranslate2 format and caches it)
        AutoTokenizer.from_pretrained('facebook/nllb-200-distilled-600M')
        from providers.plugins.translation_plugins.nllb_ctranslate2 import _get_ct2_model_path
        _get_ct2_model_path('facebook/nllb-200-distilled-600M')
        print('  [OK] NLLB-200 loaded')

        # Supertonic TTS
        TTS(auto_download=True)
        print('  [OK] Supertonic TTS loaded')

        print('All models loaded successfully.')
        break
    except Exception as e:
        print(f'Error loading models (attempt {attempt+1}): {e}')
        if attempt == 2:
            print('Failed to load models after 3 attempts. Proceeding anyway...')
        else:
            time.sleep(5)
"

echo "Starting Gunicorn..."
exec gunicorn -c /app/gunicorn.conf.py transcribe_server:app
