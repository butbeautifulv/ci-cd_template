# B5 — Dockerfile lint

## Цель

Автоматическая проверка Dockerfile.

## DAF

- `T-CODE-DOCKERFS-2-1`, `T-PREPROD-MANSEC-1-1`

## Файлы PR

- `templates/gitlab/jobs/dockerfile-lint.yml`
- `templates/github/workflows/jobs/dockerfile-lint.yml`
- `docs/phases/B5-dockerfile.md`

## Trigger

Only if `Dockerfile*` changed (`Dockerfile`, `Dockerfile.*`, `**/Dockerfile`).

GitHub: scans all matching files each run. GitLab: `rules:changes` on same paths.

## Gate

warn → block after 2 sprints (policy changelog).

## Runbook

Production patterns: [docker-production-baseline.md](../runbooks/docker-production-baseline.md)

## Контрольная точка B

MR pipeline: 5 security jobs, SARIF format, `03-security-controls` status baseline.
