# C3 — Trusted registry

## DAF: `T-ADI-ART-1-1`, `T-ADI-ART-2-1`, `T-CODE-SC-2-2`

## Файлы

- [`config/artifact-registry.yaml`](../config/artifact-registry.yaml) — backend manifest (gitlab / nexus / harbor / generic)
- [`templates/gitlab/jobs/registry/`](../templates/gitlab/jobs/registry/) — CI variables + login snippet
- [`scripts/registry-login.sh`](../scripts/registry-login.sh) — docker login abstraction
- [`docs/runbooks/nexus-docker-registry.md`](../runbooks/nexus-docker-registry.md)
- [`templates/k8s/cluster/image-pull-policy.md`](../templates/k8s/cluster/image-pull-policy.md)
- env `REGISTRY` in [`templates/gitlab/jobs/_base.yml`](../templates/gitlab/jobs/_base.yml)

## CI variables

| Backend | Variables |
|---------|-----------|
| GitLab (default) | `REGISTRY=${CI_REGISTRY_IMAGE}`, `CI_REGISTRY_*` |
| Nexus / Harbor | `REGISTRY_BACKEND`, `REGISTRY_HOST`, `REGISTRY_REPOSITORY`, `REGISTRY_USER`, `REGISTRY_PASSWORD` |

## Gate

Network policy — pull only from internal proxy / trusted registry (Kyverno `trusted-registry-only`).
