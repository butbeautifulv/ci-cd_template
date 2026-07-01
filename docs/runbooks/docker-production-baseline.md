# Docker production baseline

Checklist for consumer Dockerfiles (from docker-expert patterns). Fabrica B5 scans all `Dockerfile*` paths.

## Build

- [ ] Multi-stage build: separate `deps`/`build` from `runtime`
- [ ] `.dockerignore` excludes `.git`, tests, IaC, docs from build context
- [ ] Pin base image digest or minor tag (`python:3.13-slim`, not `latest`)
- [ ] `pip install --no-cache-dir` or `uv sync --frozen` in deps stage only
- [ ] Copy application with `--chown=nonroot:nonroot`

## Security

- [ ] Run as non-root (`USER` with dedicated UID/GID ≥ 10000)
- [ ] No secrets in `ENV` or `ARG` (use runtime secrets / BuildKit secrets)
- [ ] Drop unnecessary packages; prefer slim/distroless runtime
- [ ] `readOnlyRootFilesystem` at runtime (K8s) + writable `/tmp` if needed

## Operations

- [ ] `HEALTHCHECK` or K8s probes (not both conflicting)
- [ ] `EXPOSE` only required ports
- [ ] Production CMD (not dev server) — e.g. gunicorn/uvicorn, not `flask run`

## CI (Fabrica B5)

- Hadolint scans `Dockerfile` and `Dockerfile.*` on MR when paths change
- Gate mode: `warn` in adopt policy → `block` after triage (`security-gate-policy.yaml`)
- Reference: [examples/sample-app/Dockerfile.hardened](../../examples/sample-app/Dockerfile.hardened)

## Related

- Phase [B5-dockerfile.md](../phases/B5-dockerfile.md)
- K8s runtime: [k8s-workload-baseline.md](k8s-workload-baseline.md)
