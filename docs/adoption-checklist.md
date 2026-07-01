# Чеклист адаптации DevSecOps

Пошаговое внедрение шаблона в существующий репозиторий.

## 0. Plan (Secure SDLC)

- [ ] Threat model: [templates/governance/threat-model-checklist.md](../templates/governance/threat-model-checklist.md)
- [ ] Фаза P1: [phases/P1-threat-model.md](phases/P1-threat-model.md)
- [ ] Три модели SDLC: [references/sdlc-mapping.md](references/sdlc-mapping.md)

## 1. Подготовка

- [ ] Оценка зрелости: [05-maturity-roadmap.md](05-maturity-roadmap.md)
- [ ] Выбор профиля: `minimal` | `shift-left` | `supply-chain` | `full` | `oss-full` | `oss-full-node` (Node/TS)
- [ ] Назначен SecChamp на команду

## 2. Копирование (автоматически)

```bash
./scripts/adopt.sh --profile shift-left --platform gitlab --target /path/to/repo
# или
./scripts/adopt.sh --profile shift-left --platform github --target /path/to/repo
# uv / Python 3.13 (auto из uv.lock):
./scripts/adopt.sh --profile shift-left --platform github --target /path/to/repo --python-stack auto --policy adopt
# production gates:
./scripts/adopt.sh --profile full --platform github --target /path/to/repo --policy strict
```

Опции: `--policy adopt|strict` (default `adopt`), `--python-stack auto|uv|pip|node` (default `auto`).

GitLab: `adopt.sh` переписывает `include:` → `.gitlab/jobs/`. `post-adopt.sh` выставляет `SECURITY_POLICY` и SAST job.

## 3. SCM (A1)

- [ ] Branch protection — [platforms/gitlab.md](platforms/gitlab.md) / [platforms/github.md](platforms/github.md)
- [ ] CODEOWNERS для security paths
- [ ] MR/PR required checks

## 4. CI настройка (A2+)

- [ ] `REGISTRY` / `ghcr.io` credentials
- [ ] `ENABLE_REAL_LINTERS=true` при готовности
- [ ] Reusable workflows: `secrets: inherit` на каждом `jobs.*.uses:` (см. [egregore-adoption-case-study.md](references/supplements/egregore-adoption-case-study.md))
- [ ] **Не использовать** `env.*` в блоке `with:` при вызове reusable workflow — только `github.*` / литералы
- [ ] Python **uv**: `adopt.sh --python-stack auto` (или `uv`) — шаблоны авто-выбирают uv при `uv.lock`; pip-only: `--python-stack pip`
- [ ] CodeQL SARIF upload: предпочитать `github/codeql-action/upload-sarif@v4` (v3 deprecated 2026)
- [ ] Pre-commit: `templates/pre-commit/.pre-commit-config.yaml`
- [ ] Self-validation: `make validate` and `make validate-helm` в каталоге fabrica
- [ ] Runbooks: [docker-production-baseline.md](runbooks/docker-production-baseline.md), [k8s-workload-baseline.md](runbooks/k8s-workload-baseline.md), [ci-pipeline-observability.md](runbooks/ci-pipeline-observability.md)
- [ ] Terraform test CI: [terraform-test-ci.md](references/supplements/terraform-test-ci.md)
- [ ] Registry backend: GitLab (default) или Nexus/Harbor — [runbooks/nexus-docker-registry.md](runbooks/nexus-docker-registry.md)

## 5. Gates (shift-left)

| Control | Mode | Blocks MR? |
|---------|------|------------|
| SAST / OSA / IaC | block C/H | yes |
| SCA (image) | block C/H on main | yes |
| Secrets / Dockerfile / Linters | warn | no (`allow_failure`) |
| Forbidden files (GitHub) | warn | no |

Policy: [config/security-gate-policy.yaml](../config/security-gate-policy.yaml)

**Day-1 adoption (noisy SAST/secrets/dockerfile):** copy [config/security-gate-policy-adopt.yaml](../config/security-gate-policy-adopt.yaml) → `security-gate-policy.yaml`, then tighten `sast.mode` to `block` after Semgrep triage. See [fstec-adaptation-case-study.md](references/supplements/fstec-adaptation-case-study.md).

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
- [ ] `security-gates-oss.yml` uses **inline jobs** (GitHub rejects reusable workflows under `workflows/jobs/`)
- [ ] `gate-and-export` receives DefectDojo via **inputs** (composite actions cannot use `vars`/`secrets` directly)
- [ ] `bash scripts/validate-github-oss.sh`
- [ ] Doc: [platforms/github-oss-full.md](platforms/github-oss-full.md)

## 14. Node/TypeScript OSS (profile `oss-full-node`)

- [ ] `./scripts/adopt.sh --profile oss-full-node --platform github --target .`
- [ ] Validate: npm scripts `typecheck`, `lint`, `test` / `test:coverage`
- [ ] Optional Compose DAST: [dast-compose-oss.yml](../templates/github/workflows/dast-compose-oss.yml)
- [ ] Sec-func: `tests/security/` (pytest) **or** Vitest `@security` / `npm run test:security`
- [ ] Doc: [platforms/github-oss-full-node.md](platforms/github-oss-full-node.md)
- [ ] Case study: [fstec-adaptation-case-study.md](references/supplements/fstec-adaptation-case-study.md)

## 15. GitLab enterprise (common-templates / Kaniko+Helm)

- [ ] Profile `oss-full-enterprise` or map vars from [gitlab-enterprise-deploy.md](references/supplements/gitlab-enterprise-deploy.md)
- [ ] Stages: `security` → `static-security-upload` → `build` → `image` → `supply-chain` → `image-security-upload` → `deploy` → `post-deploy`
- [ ] ASPM upload waves: `DEFECTDOJO_URL` + `DEFECTDOJO_API_TOKEN` (both required)
- [ ] DAST opt-in: set `DAST_WEBSITE` or non-placeholder `PREPROD_URL`
- [ ] Kill-switch: `SAST_DISABLED=true` disables security + ASPM uploads
- [ ] Day-1 warn policy: [security-gate-policy-adopt.yaml](../config/security-gate-policy-adopt.yaml)
- [ ] Case study: [common-templates-adaptation-case-study.md](references/supplements/common-templates-adaptation-case-study.md)

## 16. Документы организации

- [ ] [07-governance-and-docs.md](07-governance-and-docs.md) — регламенты DSO

См. [quickstart.md](quickstart.md).
