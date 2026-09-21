# GLB Generator Secondary Backend

Verified Secondary Railway backend for GLB Generator Pro.

## Production

- Public URL: `https://glb-generator-secondary-github-production.up.railway.app`
- Health: `/health`
- Port: `8000`
- Verified deployment: `cb064714-7e3b-4528-9898-7af382ec0422`
- Verified source commit: `cce805d051612446c0736d7621cdeea3f8848f25`

The public health endpoint returns HTTP 200.

## Runtime fix

The upstream `blenderkit/headless-blender` image starts a VNC desktop through its inherited ENTRYPOINT. A direct image deployment therefore produced HTTP 502 because Uvicorn was not listening on port 8000.

This repository fixes the runtime with:

```dockerfile
ENTRYPOINT []
```

The backend source bundle is split into GitHub-safe chunks under `bundle_parts/`, reconstructed during Docker build, and SHA-256 verified before extraction. Uvicorn is then the foreground API process.

## Railway variables

Configure the application variables used by the backend, including the client token, public base URL, data directory, Blender executable, worker polling, timeouts, and fidelity limits. Secrets should remain in Railway variables rather than this repository.
