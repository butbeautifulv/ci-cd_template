# A2 — CI/CD base

## Цель

Пустой, но правильный pipeline без security jobs.

## DAF

- `T-DEV-CICD-1-3`, `T-DEV-CICD-1-1`, `T-DEV-BLD-1-4`

## Файлы PR

- `templates/gitlab/.gitlab-ci.yml`
- `templates/gitlab/jobs/_base.yml`
- `templates/github/workflows/ci.yml`
- `config/security-gate-policy.yaml` (version + defaults)
- `docs/phases/A2-cicd-base.md`

## Stages

`validate → test → build` (deploy manual stub)

## Gate

Pipeline зелёный на fork.

## Критерии приёмки

- [x] MR и main триггерят pipeline
- [x] Логи доступны (GitLab job logs / GitHub Actions)

## Rollback

Удалить `templates/` includes из проекта.

## Следующий шаг

[B1-secrets.md](B1-secrets.md)
