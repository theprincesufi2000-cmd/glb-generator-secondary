FROM blenderkit/headless-blender:blender-4.5-stable

# Railway secondary backend: the upstream image launches VNC through its
# inherited ENTRYPOINT. Clear it so Uvicorn is PID 1.
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

# Reconstruct the tested backend bundle, then overlay the v5.2.8 Blender
# UV-safety patch before byte-compiling the backend.
COPY bundle_parts /tmp/bundle_parts
COPY patches/refine_glb_v528.py.xz.b64 /tmp/refine_glb_v528.py.xz.b64

RUN cat /tmp/bundle_parts/backend.part.* > /tmp/backend.tar.xz.b64 \
    && base64 -d /tmp/backend.tar.xz.b64 > /tmp/backend.tar.xz \
    && echo "370c2c35efa65a9e5f980eb5756176e047e84fad9ff57196f035a85304bdd41c  /tmp/backend.tar.xz" | sha256sum -c - \
    && tar -xJf /tmp/backend.tar.xz -C /app \
    && base64 -d /tmp/refine_glb_v528.py.xz.b64 | xz -d > /app/blender/refine_glb.py \
    && echo "080b0b8cb73c223f8bf697fd31292473072aef7977dd02b83a79f26c8cada34d  /app/blender/refine_glb.py" | sha256sum -c - \
    && test -f /app/requirements.txt \
    && python3 -m pip install --break-system-packages --no-cache-dir -r /app/requirements.txt \
    && python3 -m py_compile /app/app/*.py /app/blender/refine_glb.py \
    && rm -rf /tmp/backend.tar.xz /tmp/backend.tar.xz.b64 /tmp/bundle_parts /tmp/refine_glb_v528.py.xz.b64

RUN mkdir -p /data/jobs

EXPOSE 8000

CMD ["/bin/sh", "-c", "exec python3 -m uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
