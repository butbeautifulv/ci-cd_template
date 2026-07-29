# Corp GitLab runners (Fabrica mirror)

How `map_objects-ci` and similar corp-offline mirrors expect GitLab runners to behave.

## Required tags

Mirror profile `default.tags`:

- `devsecops`
- `k3s`
- `corp`
- `p30`

These tags may match **more than one** executor on the same GitLab “runner” registration (shell + kubernetes). Jobs must not assume only one.

## Shell vs Kubernetes

| Executor | Typical host line | Docker API | Job `image:` |
|----------|-------------------|------------|--------------|
| Shell (`p30-k3s-shell`) | `Running on bbv-P30-…` | Host `/var/run/docker.sock` | Often **ignored** — use `docker run ${OSS_*_IMAGE}` |
| Kubernetes (`cxado-k8s`) | `Using Kubernetes executor` | DinD sidecar `tcp://docker:2376` + TLS under `/certs` | Honored (must be **literal** Nexus refs) |

### Build jobs

Always source [`scripts/docker-host-bootstrap.sh`](../../scripts/docker-host-bootstrap.sh) before `docker` / `registry-login`:

- If `/var/run/docker.sock` exists → `DOCKER_HOST=unix:///var/run/docker.sock`
- Else if DinD certs exist → `DOCKER_HOST=tcp://docker:2376` + TLS verify
- Wait until `docker info` succeeds

Without bootstrap, k8s jobs fail with `dial unix /var/run/docker.sock: no such file`.

### Nested `image:` variables

Kubernetes executor does **not** expand nested `${NEXUS_DOCKER_PREFIX}/…` reliably → falls back to alpine → soft-green uploads. Mirror profile must use full literals, e.g. `nexus.svo.aero:8345/library/python:3.11.11-slim-bookworm`.

## Trivy cache on shared shell workspace

OSA/SCA share `.trivy-cache` as an artifact. Docker-as-root leaves `db/` root-owned → next job’s `git clean` fails with Permission denied.

Mitigations (mirror profile + jobs):

- `GIT_CLEAN_FLAGS: "-ffdx -e .trivy-cache -e .trivy-cache/**"`
- `docker run --user "$(id -u):$(id -g)"` for Trivy
- SCA prefers `--skip-db-update` after OSA warmed the cache

## TLS / corp CA

| Path | Role |
|------|------|
| `/etc/ssl/certs/nexus/ca.crt` | Preferred; set `SSL_CERT_FILE` |
| `TRIVY_INSECURE=true` | Temporary MITM bypass for Nexus `:8374` Trivy DB |
| `DEFECTDOJO_INSECURE=true` | NodePort TLS gateway until CA mounted |

Long-term: mount corp CA into CI pods and drop `TRIVY_INSECURE` / `DEFECTDOJO_INSECURE`.

Map `NEXUS_USER`/`NEXUS_PASSWORD` → `TRIVY_USERNAME`/`TRIVY_PASSWORD` for authenticated OCI pulls of `aquasecurity/trivy-db` via Nexus group `:8374`.

## Required Nexus image pins (N8 inventory)

Corp offline: all tool images from Nexus only (`:8345` Docker Hub proxy, `:8374` GHCR/group). Keep these tags present before pilots:

| Role | Example ref |
|------|-------------|
| Python / uploads / linters | `nexus.svo.aero:8345/library/python:3.11.11-slim-bookworm` |
| Trivy | `nexus.svo.aero:8345/aquasec/trivy:0.67.2` |
| Trivy DB (OCI) | `nexus.svo.aero:8374/aquasecurity/trivy-db` (+ java-db) |
| Gitleaks | `nexus.svo.aero:8374/gitleaks/gitleaks:v8.22.1` |
| Semgrep | `nexus.svo.aero:8345/returntocorp/semgrep:1.117.0` |
| Checkov | `nexus.svo.aero:8345/bridgecrew/checkov:3.2.449` |
| Hadolint | `nexus.svo.aero:8345/hadolint/hadolint:v2.12.0-alpine` |
| Docker CLI / DinD | `nexus.svo.aero:8345/library/docker:29.3.1-cli` / `…-dind` |

Mirror helper: monorepo `scripts/gitlab/mirror-fabrica-ci-images.sh` (ops).

## DefectDojo from runners

See [`aspm-export.md`](aspm-export.md): shell runners must use NodePort IP `:30808`, not in-cluster DNS.

## Kaniko backlog

Build today uses docker CLI + host sock or DinD. Migrating to Kaniko is a separate hardening slice; do not block multi-service evidence on it.
