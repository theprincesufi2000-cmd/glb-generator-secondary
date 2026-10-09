
FROM blenderkit/headless-blender:blender-4.5-stable

ENTRYPOINT []
USER root

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    GLB_DATA_DIR=/data \
    GLB_BLENDER_EXECUTABLE=/home/headless/blender/blender \
    GLB_STRICT_GEOMETRIC_TEXTURES=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY GLB-generator-Pro-v5.5.0-Verified-Projection-Backend-Railway.zip /tmp/backend.zip

RUN unzip -q /tmp/backend.zip -d /tmp/backend-src && \
    cp -a /tmp/backend-src/backend/. /app/ && \
    test -f /app/app/main.py && \
    test -f /app/blender/multiview_baker.py && \
    python3 -m pip install \
    --break-system-packages \
    --no-cache-dir \
    --ignore-installed \
    -r /app/requirements.txt && \
    python3 -m py_compile /app/app/*.py /app/blender/*.py && \
    rm -rf /tmp/backend-src /tmp/backend.zip

RUN mkdir -p /data/jobs

EXPOSE 8000

CMD ["/bin/sh", "-c", "exec python3 -m uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
