# F1 — IAST (preprod)

## Источник: финтех-PDF | DAF: `T-PREPROD-DAST-3-3`

## OSS в шаблоне (profile `oss-full` / `full`)

**F1 реализован без commercial-агентов:** OWASP ZAP **Full Scan** (`zap-full-scan.py`) — active spider + runtime probes против preprod.

| Платформа | Job / workflow |
|-----------|----------------|
| GitLab | `iast-preprod` → `templates/gitlab/jobs/iast-preprod.yml` |
| GitHub | `jobs/oss/iast-preprod.yml`, `iast-oss.yml` (`workflow_dispatch`) |

Переменные: `PREPROD_URL`, `ZAP_IAST_MAX_MIN` (default 15). Gate: `iast:` в policy (mode `info`, не блокирует CI по умолчанию). Findings → DefectDojo (`aspm-export`, scan type ZAP).

## Commercial IAST (опционально)

Contrast, Seeker, Hdiv, CxIAST — in-process instrumentation; требуют лицензию и agent inject в runtime. Настраивается **поверх** OSS job или вместо него по runbook SecChamp.

## Файлы

- `docs/phases/F1-iast.md` (этот документ)
- `templates/gitlab/jobs/iast-preprod.yml`
- `templates/github/workflows/jobs/oss/iast-preprod.yml`
