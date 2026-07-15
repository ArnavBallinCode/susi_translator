FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=transcribe_server.py

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    ffmpeg \
    build-essential \
    python3-dev \
    portaudio19-dev \
    python3-pyaudio \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv to a system-wide location so all users (including non-root) can access it
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv

# Create a non-root user for running the application
RUN useradd --create-home --shell /bin/bash --uid 1001 appuser

WORKDIR /app

# Copy lockfiles from repo root 
COPY pyproject.toml uv.lock ./

# Ensure the virtualenv created by `uv sync` is in the PATH
ENV PATH="/app/.venv/bin:$PATH"

# Redirect model/library caches away from /root into the mounted volume
ENV XDG_CACHE_HOME=/app/.cache

# Install all production deps from the pinned lockfile
RUN uv sync --frozen --no-dev

# Copy the gunicorn config
COPY gunicorn.conf.py /app/gunicorn.conf.py

# Copy Flask application code and entrypoint
COPY flask/ .
RUN chmod +x /app/entrypoint.sh \
    && chown -R appuser:appuser /app

EXPOSE 5040

USER appuser

ENTRYPOINT ["/app/entrypoint.sh"]