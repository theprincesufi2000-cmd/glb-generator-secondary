FROM blenderkit/headless-blender:blender-4.5-stable

# Keep Uvicorn as PID 1; inherited Blender image entrypoint starts VNC.
ENTRYPOINT []
USER root
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    GLB_DATA_DIR=/data \
    GLB_BLENDER_EXECUTABLE=/home/headless/blender/blender

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Verified v5.4.0 full source: no v5.2.x overlay patches.
COPY backend_v540.tar.xz.b64 /tmp/backend_v540.tar.xz.b64
RUN base64 -d /tmp/backend_v540.tar.xz.b64 > /tmp/backend_v540.tar.xz \
    && echo '43af9ce1a6caf4d89a9ffa45cdd5d5e59b153f0bf433496c5ed6e557d6aec24d  /tmp/backend_v540.tar.xz' | sha256sum -c - \
    && tar -xJf /tmp/backend_v540.tar.xz -C /app \
    && test -f /app/app/main.py \
    && test -f /app/blender/multiview_baker.py \
    && python3 -m pip install --break-system-packages --no-cache-dir --ignore-installed -r /app/requirements.txt \
    && python3 -m py_compile /app/app/*.py /app/blender/*.py \
    && rm -f /tmp/backend_v540.tar.xz.b64 /tmp/backend_v540.tar.xz

RUN mkdir -p /data/jobs
EXPOSE 8000
CMD ["/bin/sh", "-c", "exec python3 -m uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
