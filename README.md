# GLB Generator Secondary Backend

Railway secondary production backend for GLB Generator Pro.

## Runtime
- Release source: v5.4.0 multiview baking, 2D/3D calibration and UV seam/occlusion processing.
- Public URL: `https://glb-generator-secondary-github-production.up.railway.app`
- Health: `/health`
- Port: `8000`
- Image: `blenderkit/headless-blender:blender-4.5-stable`

## Source packaging
`backend_v540.tar.xz.b64` contains source under `app/`, `blender/` and `requirements.txt`.
`Dockerfile` verifies SHA-256 of the decoded archive before unpacking it.
Older v5.2.x `bundle_parts/` and `patches/` are legacy and are not used by this Dockerfile.

## Security
Keep tokens, backend settings and private values in Railway environment variables.
Never commit secrets into GitHub.

## Validation
Railway health check is configured in `railway.toml` as `/health`.
Functional Blender bake quality must be tested using a genuine multi-view job.
