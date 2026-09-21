# GLB Generator Secondary Backend

Secondary Railway backend for GLB Generator Pro v5.2.4.

## Why this repository exists

The upstream `blenderkit/headless-blender` image starts a VNC desktop through its inherited ENTRYPOINT. A direct Railway image service therefore returned HTTP 502 because Uvicorn never listened on port 8000.

This Dockerfile fixes that by clearing the inherited entrypoint with:

```dockerfile
ENTRYPOINT []
```

and then starts the tested GLB backend on Railway's `PORT`.

## Railway

Required variables:

- `BACKEND_XZ_B64` — tested backend bundle
- `GLB_CLIENT_TOKEN`
- `GLB_DATA_DIR=/data`
- `GLB_PUBLIC_BASE_URL=https://<secondary-domain>`
- `GLB_BLENDER_EXECUTABLE=/home/headless/blender/blender`
- `GLB_BLENDER_TIMEOUT_SECONDS=5400`
- `GLB_WORKER_POLL_SECONDS=2`
- `GLB_PROVIDER_RETRY_MINUTES=180`

Healthcheck: `/health`

Container port: `8000`
