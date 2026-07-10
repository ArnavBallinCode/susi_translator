#!/bin/bash
set -e

echo "Running database migrations..."
uv run python -m flask --app transcribe_server.py db upgrade

echo "Starting Gunicorn..."
exec gunicorn -c /app/gunicorn.conf.py transcribe_server:app
