# B6 — Security linters

## Цель

Style + security linters на MR (финтех swimlane: «Линтеры» параллельно SAST).

## DAF

- `T-DEV-SRC-3-*` — контроль качества и безопасности кода
- Финтех MR gate: линтеры style + security

## Файлы PR

- `templates/gitlab/jobs/linter-security.yml`
- `templates/github/workflows/jobs/linter-security.yml`
- `config/security-gate-policy.yaml` → `linters:`
- `docs/phases/B6-linter-security.md`

## Gate

Warn Critical/High on MR (`linters.mode: warn`). Pipeline не блокирует merge; findings в отчёте.

## Enable real linters

```yaml
# GitLab CI/CD variables or profile default
ENABLE_REAL_LINTERS: "true"
```

При `false` — stub (exit 0), для scaffold/adopt без настройки toolchain.

## Acceptance

- [ ] Job в `shift-left` profile
- [ ] `gate-check.py --control linters` без `|| true`
- [ ] `ENABLE_REAL_LINTERS` документирован в adoption-checklist

## Rollback

Remove `linter-security.yml` include.
