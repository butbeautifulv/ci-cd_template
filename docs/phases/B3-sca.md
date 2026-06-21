# B3 — OSA/SCA

## Цель

Анализ зависимостей + SBOM draft.

## DAF

- `T-CODE-SC-2-4`, `T-ADI-DEP-3-2`, `T-ADI-DEP-1-5`

## Файлы PR

- `templates/gitlab/jobs/sca.yml`
- `templates/github/workflows/jobs/sca.yml`
- `templates/github/dependabot.yml`
- `config/security-gate-policy.yaml` → `sca:`
- `docs/phases/B3-sca.md`

## Gate

Block Critical в прямых зависимостях; транзитивные — warn.

## Rollback

Remove sca job + dependabot.
