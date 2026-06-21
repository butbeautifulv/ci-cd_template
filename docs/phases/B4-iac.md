# B4 — IaC scan

## Цель

Сканирование Terraform, K8s, Helm.

## DAF

- `T-PREPROD-MANSEC-2-1`, `T-PROD-ACCESS-1-3`

## JCSF

- Domain `man` — `Man-*` L1

## Файлы PR

- `templates/gitlab/jobs/iac-scan.yml`
- `templates/github/workflows/jobs/iac-scan.yml`
- `config/security-gate-policy.yaml` → `iac:`
- `docs/phases/B4-iac.md`

## Paths

`**/*.tf`, `**/k8s/**`, `**/helm/**`, `docker-compose*.yml`

## Gate

Block High/Critical misconfigs on MR.

## Acceptance

- [x] `gate-check.py --control iac` без `|| true` на MR
- [ ] Проверено на `examples/sample-app` (known IaC findings)
