FROM blenderkit/headless-blender:blender-4.5-stable

# The upstream image starts a VNC desktop through its inherited ENTRYPOINT.
# Railway must run the API process instead.
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
COPY backend.tar.xz.b64 /tmp/backend.tar.xz.b64

# Decode and install the exact tested backend at image build time. This avoids
# runtime failures caused by missing/staged Railway base64 variables.
RUN base64 -d /tmp/backend.tar.xz.b64 > /tmp/backend.tar.xz \
    && echo "370c2c35efa65a9e5f980eb5756176e047e84fad9ff57196f035a85304bdd41c  /tmp/backend.tar.xz" | sha256sum -c - \
    && tar -xJf /tmp/backend.tar.xz -C /app \
    && test -f /app/requirements.txt \
    && python3 -m pip install --break-system-packages --no-cache-dir -r /app/requirements.txt \
    && python3 -m py_compile /app/app/*.py /app/blender/refine_glb.py \
    && rm -f /tmp/backend.tar.xz /tmp/backend.tar.xz.b64

RUN mkdir -p /data/jobs

EXPOSE 8000
CMD ["/bin/sh", "-c", "exec python3 -m uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
