# C2 — SCA (container image scan)

## Цель

**SCA** (DAF 4.3.3) — композиционный анализ **собранного образа** после build и SBOM (`T-CODE-SC-2-4` на этапе сборки).

Отличие от **OSA (B3)**: OSA сканирует манифесты в репо на MR; SCA — CVE в слоях образа (OS + deps).

## DAF / JCSF

- `T-CODE-IMG-2-1`, `T-CODE-IMG-4-2` | JCSF: `Img-*`

## Файлы

- `templates/gitlab/jobs/container-scan.yml` — job `container_scanning`, gate `sca:`
- `templates/gitlab/jobs/oss/trivy-sca.yml` (profile `oss-full`)
- `templates/github/workflows/jobs/sca-image.yml`
- `config/security-gate-policy.yaml` → `sca:` (alias `container:`)

## Gate

Block Critical/High CVE in image. Stage: `build`, `needs: [build-image, sbom-generate]`.

## Rollback

Remove container-scan job + `sca:` policy section.
