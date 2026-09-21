FROM blenderkit/headless-blender:blender-4.5-stable

# The upstream image ships a VNC desktop ENTRYPOINT. Railway must run our API
# process instead, so clear the inherited entrypoint completely.
ENTRYPOINT []

USER root
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    GLB_DATA_DIR=/data \
    GLB_BLENDER_EXECUTABLE=/home/headless/blender/blender

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-pip xz-utils ca-certificates \
    && python3 -m pip install --break-system-packages --no-cache-dir \
       fastapi==0.128.2 \
       "uvicorn[standard]==0.48.0" \
       python-multipart==0.0.29 \
       gradio_client==2.0.3 \
       Pillow==11.3.0 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app /data/jobs
WORKDIR /app
EXPOSE 8000

# BACKEND_XZ_B64 contains the tested backend source bundle. Decode it at runtime
# so this service always runs the same backend payload as the Android project.
CMD ["/bin/sh", "-c", "set -e; printf %s \"$BACKEND_XZ_B64\" | base64 -d > /tmp/backend.tar.xz; echo \"ffc9ffe4b73c5647aad479e929b98cba1b530b143cc81c9fced435a25c7536ea  /tmp/backend.tar.xz\" | sha256sum -c -; tar -xJf /tmp/backend.tar.xz -C /app; python3 -m py_compile /app/app/*.py /app/blender/refine_glb.py; exec python3 -m uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
