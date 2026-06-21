# B2 — SAST

## Цель

Статический анализ на MR и main.

## DAF

- `T-CODE-SST-2-3`, `T-CODE-SST-1-2`, `T-DEV-SRC-3-6`

## Файлы PR

- `templates/gitlab/jobs/sast.yml`
- `templates/github/workflows/jobs/sast.yml`
- `config/security-gate-policy.yaml` → `sast:`
- `docs/phases/B2-sast.md`

## Gate

Block Critical/High on MR.

## Ignore policy

`.semgrepignore` / CodeQL config — review SecChamp.

## Rollback

Remove `sast.yml` include.
