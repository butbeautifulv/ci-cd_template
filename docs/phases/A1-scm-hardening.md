# A1 — SCM hardening

## Цель

Защита репозитория до подключения security-сканеров.

## DAF / JCSF

- `T-DEV-SCM-1-*`, `T-DEV-SRC-1-5`, `T-DEV-SRC-2-6`

## Файлы PR

- `docs/phases/A1-scm-hardening.md`
- `docs/platforms/gitlab.md` (секция A1)
- `docs/platforms/github.md` (секция A1)
- `templates/CODEOWNERS`

## Инструменты

Ручная настройка SCM (не CI).

## Gate

Ручной аудит + скриншоты в тикете.

## Критерии приёмки

- [x] Protected `main`, 2 approvals, linear history
- [x] CODEOWNERS на security paths
- [x] Push rules / branch protection documented

## Rollback

Откат настроек SCM в UI.

## Следующий шаг

[A2-cicd-base.md](A2-cicd-base.md)
