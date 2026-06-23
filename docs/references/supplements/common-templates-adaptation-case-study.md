# common-templates adaptation case study

Adaptation of `ci-cd_template` patterns into **GitLab include library** [`seps/ci-cd/common-templates`](.external/common-templates%20(Copy)) (Kaniko + Helm, enterprise GitLab).

**Source log:** [common-templates-adaptation-log.md](.external/common-templates%20(Copy)/common-templates-adaptation-log.md)

## Context

| Parameter | common-templates | ci-cd_template default |
|-----------|------------------|------------------------|
| Consumer model | `include: template.yaml` library | `adopt.sh` copies jobs into repo |
| Deploy | Kaniko + Helm (unchanged) | Docker build + Helm sample chart |
| Gate mode | Warn-only (`allow_failure: true`) | Policy gates via `gate-check.py` |
| DAST trigger | Opt-in `DAST_WEBSITE` | Manual + opt-in `PREPROD_URL` / `DAST_WEBSITE` |

## What was adopted into ci-cd_template

| Pattern | Implementation |
|---------|----------------|
| Stage rename v2 | `oss-full-enterprise` profile: `security` → `supply-chain` → `post-deploy` |
| ASPM upload waves | [`aspm/upload-static.yml`](../../templates/gitlab/jobs/aspm/upload-static.yml), [`upload-image.yml`](../../templates/gitlab/jobs/aspm/upload-image.yml) |
| Kill-switch | `SAST_DISABLED` / `SECURITY_DISABLED` in [`_security.common.yml`](../../templates/gitlab/jobs/_security.common.yml) |
| DAST opt-in | [`dast.yml`](../../templates/gitlab/jobs/dast.yml) rules on `DAST_WEBSITE` / non-placeholder `PREPROD_URL` |
| DefectDojo skip | URL **and** token required; `--skip-empty` on upload jobs |
| Dual-format reports | Checkov JSON + SARIF; Hadolint JSON + SARIF for Dojo vs gates |
| Multi-contour Helm | [`helm-deploy-contour.yml`](../../templates/gitlab/jobs/oss/helm-deploy-contour.yml) |

## Deferred in common-templates (available in ci-cd_template)

| Control | common-templates | ci-cd_template |
|---------|------------------|----------------|
| Blocking gates | Deferred | `gate-check.py` + policy YAML |
| Cosign | No PKI | `sign.yml` / `sign-oss.yml` |
| Conftest admission | Cluster scope | `conftest-admission.yml` |
| Ruff B6 | No single language stack | `linter-security.yml` / Node profile |

## Stage migration (v2)

| Old stage | New stage |
|-----------|-----------|
| `test` (security only) | `security` |
| `image-scan` | `supply-chain` |
| `dast` before deploy | `post-deploy` after `deploy` |

## Profiles

```bash
# Standard OSS + upload waves
./scripts/adopt.sh --profile oss-full --platform gitlab --target .

# Enterprise stage names (common-templates compatible)
cp templates/profiles/oss-full-enterprise.gitlab-ci.yml .gitlab-ci.yml
# Fix include paths: local: '.gitlab/jobs/...'
```

## Deploy-safe modes

See [02-pipeline-architecture.md](../../02-pipeline-architecture.md#deploy-safe-security-modes) and [gitlab-enterprise-deploy.md](gitlab-enterprise-deploy.md).

## Related

- [fstec-adaptation-case-study.md](fstec-adaptation-case-study.md) — GitHub mechanics
- [gitlab-oss-full.md](../../platforms/gitlab-oss-full.md)
