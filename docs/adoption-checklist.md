# Чеклист адаптации DevSecOps

Пошаговое внедрение шаблона в существующий репозиторий.

## 0. Plan (Secure SDLC)

- [ ] Threat model: [templates/governance/threat-model-checklist.md](../templates/governance/threat-model-checklist.md)
- [ ] Фаза P1: [phases/P1-threat-model.md](phases/P1-threat-model.md)
- [ ] Три модели SDLC: [references/sdlc-mapping.md](references/sdlc-mapping.md)

## 1. Подготовка

- [ ] Оценка зрелости: [05-maturity-roadmap.md](05-maturity-roadmap.md)
- [ ] Выбор профиля: `minimal` | `shift-left` | `supply-chain` | `full`
- [ ] Назначен SecChamp на команду

## 2. Копирование (автоматически)

```bash
./scripts/adopt.sh --profile shift-left --platform gitlab --target /path/to/repo
# или
./scripts/adopt.sh --profile shift-left --platform github --target /path/to/repo
```

GitLab: `adopt.sh` переписывает `include:` → `.gitlab/jobs/`.

## 3. SCM (A1)

- [ ] Branch protection — [platforms/gitlab.md](platforms/gitlab.md) / [platforms/github.md](platforms/github.md)
- [ ] CODEOWNERS для security paths
- [ ] MR/PR required checks

## 4. CI настройка (A2+)

- [ ] `REGISTRY` / `ghcr.io` credentials
- [ ] `ENABLE_REAL_LINTERS=true` при готовности
- [ ] Pre-commit: `templates/pre-commit/.pre-commit-config.yaml`
- [ ] Self-validation: `bash scripts/validate-yaml.sh`, `python3 scripts/validate-policy.py`, `bash scripts/validate-oss-pins.sh`, `bash scripts/validate-registry-config.sh`
- [ ] Registry backend: GitLab (default) или Nexus/Harbor — [runbooks/nexus-docker-registry.md](runbooks/nexus-docker-registry.md)

## 5. Gates (shift-left)

| Control | Mode | Blocks MR? |
|---------|------|------------|
| SAST / OSA / IaC | block C/H | yes |
| SCA (image) | block C/H on main | yes |
| Secrets / Dockerfile / Linters | warn | no (`allow_failure`) |
| Forbidden files | warn | no |

Policy: [config/security-gate-policy.yaml](../config/security-gate-policy.yaml)

## 6. По фазам

| Фаза | Проверка |
|------|----------|
| B1 | Secret scan + gate-check |
| B2 | SAST SARIF, block C/H |
| B3 | OSA block critical (manifests) |
| C2 | SCA block critical/high (image) |
| B4 | IaC block C/H |
| B5 | Dockerfile hadolint (warn) |
| B6 | [B6-linter-security.md](phases/B6-linter-security.md) |
| C1 | `sbom.cdx.json` + gate on main |
| C2 | Container scan SARIF |
| C3 | Internal registry only |
| C4 | cosign manual |
| D1 | DAST + gate (warn) |
| D2 | pytest `@security` + gate |
| D3 | Release gate checklist |
| E1–E4 | K8s policies apply |
| F1–F3 | IAST manual, WAF runbook |

## 7. Валидация на sample-app

```bash
cd examples/sample-app
python3 ../../scripts/gate-check.py --control sast --report /path/to/report.sarif
# локальные сканы — см. examples/sample-app/README.md
```

## 8. ASTO / ASPM

- [ ] `DEFECTDOJO_URL` + `DEFECTDOJO_API_TOKEN` in CI/CD variables
- [ ] Review mapping in `config/aspm-export.yaml`
- [ ] Runbook: [runbooks/aspm-export.md](runbooks/aspm-export.md)
- [ ] SLA на findings

## 9. Compliance / audits

- [ ] GOST mapping: [references/extracts/daf/ГОСТ56939_mapping.md](references/extracts/daf/ГОСТ56939_mapping.md)
- [ ] JCSF extracts: [references/extracts/jcsf/](references/extracts/jcsf/)

## 10. Out of CI (явно)

Performance, Chaos ([F4-resilience.md](phases/F4-resilience.md)), PKI ([runbooks/pki-k8s.md](runbooks/pki-k8s.md)) — runbooks only.

## 11. AI/ML optional (profile `ai-ml`)

- [ ] `./scripts/adopt.sh --profile ai-ml --platform gitlab --target .`
- [ ] Demo: [examples/sample-ml-app/](examples/sample-ml-app/)
- [ ] ML1 PII gate — [phases/ML1-data-scan.md](phases/ML1-data-scan.md)
- [ ] AI1 skills — [phases/AI1-skill-scan.md](phases/AI1-skill-scan.md)
- [ ] Runtime — [runbooks/ai-runtime-guardrails.md](runbooks/ai-runtime-guardrails.md)

## 12. OSS tool pins (profile `oss-full`)

- [ ] `config/oss-tool-versions.yaml` copied on adopt
- [ ] `bash scripts/validate-oss-pins.sh` passes (no `:latest` / Trivy `main`)
- [ ] Runbook: [runbooks/oss-tool-pinning.md](runbooks/oss-tool-pinning.md)

## 13. GitHub OSS full (profile `oss-full` + platform `github`)

- [ ] `./scripts/adopt.sh --profile oss-full --platform github --target .`
- [ ] GHCR enabled (packages: write permission)
- [ ] `bash scripts/validate-github-oss.sh`
- [ ] Doc: [platforms/github-oss-full.md](platforms/github-oss-full.md)

## 14. Документы организации

- [ ] [07-governance-and-docs.md](07-governance-and-docs.md) — регламенты DSO

См. [quickstart.md](quickstart.md).
