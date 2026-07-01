# E4 — SIEM correlation

## DAF: `T-PROD-EVENTS-3-1`

## Файлы: `docs/phases/E4-siem.md`, `templates/siem/rules/container-security/*.yml`

## CI diff: 0. Container Security events → SIEM rules.

## Observability

- CI gate dashboards (RED/USE): [ci-pipeline-observability.md](../runbooks/ci-pipeline-observability.md)
- Runtime SIEM rules: `templates/siem/rules/container-security/`
- cxado unified stack: meta-repo `deploy/observability/`

## Контрольная точка E

Cluster rejects privileged; default-deny network; Falco → SIEM; CI gate failure trends visible in Grafana.
