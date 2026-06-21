# P0 — Scaffold

## Цель

Навигационный каркас документации без исполняемого CI.

## DAF / JCSF

Обзор всех доменов DAF (без оценки зрелости).

## Execution plan

Hardening tracked in [`.cursor/plans/devsecops-execution.plan.md`](../../.cursor/plans/devsecops-execution.plan.md).

## Файлы PR

- `README.md`
- `docs/00-master-plan.md` … `docs/08-compliance-gost-56939.md`
- `docs/platforms/gitlab.md`, `docs/platforms/github.md`
- `docs/references/sources.md`
- `docs/phases/P0-scaffold.md`

## Инструменты

Нет.

## Gate

Нет.

## Критерии приёмки

- [x] Ссылки между docs валидны
- [x] Матрица контролей в `03-security-controls.md` полная
- [x] README описывает порядок подфаз P0→F3
- [x] Execution plan + AGENTS.md зафиксированы (CF-1)

## Rollback

Удалить каталог `docs/` и `README.md`.

## Следующий шаг

[A1-scm-hardening.md](A1-scm-hardening.md)
