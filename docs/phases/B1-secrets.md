# B1 — Secret detection

## Цель

Первый автоматический контроль в MR.

## DAF

- `T-CODE-SECDN-1-1`, `T-CODE-SECDN-2-1`

## Файлы PR

- `templates/gitlab/jobs/secret-scan.yml`
- `templates/github/workflows/jobs/secret-scan.yml`
- `config/security-gate-policy.yaml` → `secrets:`
- `docs/phases/B1-secrets.md`

## Инструменты

- GitLab: Secret-Detection template
- GitHub: Gitleaks action

## Gate

**warn only** (B1); block verified secrets — отдельный микро-PR.

## Критерии приёмки

- [x] SARIF/JSON artifact 30d retention
- [x] MR + main triggers

## Rollback

Remove include `secret-scan.yml`.
