# B3 — OSA (Open Source Analysis)

## Цель

Анализ **манифестов зависимостей** в репозитории на MR (DAF 4.3.2): `requirements.txt`, lock-файлы, `go.mod`, `package.json`.

Отличие от **SCA (C2)**: OSA — Code/MR; SCA — образ контейнера после сборки и SBOM.

## DAF

- `T-CODE-SC-0-1`, `T-CODE-SC-2-4`, `T-ADI-DEP-3-2`

## Файлы PR

- `templates/gitlab/jobs/osa.yml`
- `templates/gitlab/jobs/oss/trivy-osa.yml` (profile `oss-full`)
- `templates/github/workflows/jobs/osa.yml`
- `config/security-gate-policy.yaml` → `osa:`

Legacy include: `sca.yml` → alias на `osa.yml`.

## Gate

Block Critical в прямых зависимостях; транзитивные — warn.

## Verification

```bash
trivy fs examples/sample-app/ --format sarif -o /tmp/osa.sarif
python3 scripts/gate-check.py --control osa --report /tmp/osa.sarif
```

## Rollback

Remove osa job + policy section `osa:`.
