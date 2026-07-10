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

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Copy lockfiles from repo root 
COPY pyproject.toml uv.lock ./

# Ensure the virtualenv created by `uv sync` is in the PATH
ENV PATH="/app/.venv/bin:$PATH"

# Install all production deps from the pinned lockfile
RUN uv sync --frozen --no-dev

# Copy the gunicorn config
COPY gunicorn.conf.py /app/gunicorn.conf.py

# Copy Flask application code
COPY flask/ .

EXPOSE 5040
CMD ["gunicorn", "-c", "/app/gunicorn.conf.py", "transcribe_server:app"]