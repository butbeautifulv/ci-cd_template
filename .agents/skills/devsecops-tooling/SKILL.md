---
name: devsecops-tooling
description: >-
  DevSecOps tool catalog by security class (SAST, SCA, DAST, IAST, RASP, WAF,
  MAST, ASPM). Use when selecting scanners, mapping full CI/CD pipeline controls,
  or picking GitLab vs GitHub / oss-full vs full profiles.
---

# DevSecOps tooling catalog

## Where everything lives (canonical docs)

| Question | Read first |
|----------|------------|
| **Full control matrix** (SAST…RASP, CI vs runtime) | [03-security-controls.md](../../docs/03-security-controls.md) |
| **Pipeline stages + diagram** (WAF/RASP in prod box) | [02-pipeline-architecture.md](../../docs/02-pipeline-architecture.md) |
| **Tool tiers** (builtin/oss/commercial) | [04-tooling-catalog.md](../../docs/04-tooling-catalog.md) |
| **oss-full job list B–F** | [oss-full-shared.md](../../docs/platforms/oss-full-shared.md) |
| **Exhaustive OCR list** (OpenRASP, 42Crunch, Nuclei, …) | [supplements/devsecops_tools.md](../../docs/references/supplements/devsecops_tools.md) |
| **SDLC ↔ jobs** | [sdlc-mapping.md](../../docs/references/sdlc-mapping.md) |

Config: `config/security-gate-policy.yaml`, `config/oss-tool-versions.yaml`, `config/aspm-export.yaml`.

---

## Full CI/CD — control → template (this repo)

**Legend:** ✅ CI job | 📋 runbook / K8s manifest | 🔧 design / optional | ❌ not in template (catalog only)

| Control | Phase | CI | GitLab / GitHub path | oss-full tool | full profile tool |
|---------|-------|----|----------------------|---------------|-------------------|
| Linters | B6 | ✅ | `linter-security.*` | Ruff (pip pin) | placeholder / Ruff |
| Secrets | B1 | ✅ | `oss/gitleaks.*` / `secret-scan.*` | Gitleaks docker | Gitleaks action |
| Forbidden files | B1+ | ✅ | `forbidden-files.yml` | shell+gate | shift-left only |
| SAST | B2 | ✅ | `oss/semgrep-sast.*` / `sast.*` | Semgrep docker | CodeQL + Semgrep |
| OSA | B3 | ✅ | `oss/trivy-osa.*` / `osa.*` | Trivy fs docker | Trivy action / dep-review |
| IaC | B4 | ✅ | `oss/checkov-iac.*` / `iac-scan.*` | Checkov pip | Checkov action |
| Dockerfile | B5 | ✅ | `dockerfile-lint.*` | Hadolint docker | hadolint-action |
| SBOM | C1 | ✅ | `sbom*.yml` | Syft docker | Syft action |
| SCA image | C2 | ✅ | `oss/trivy-sca.*` / `container-scan.*` | Trivy image docker | trivy-action |
| Sign | C4 | ✅ | `sign*.yml` | cosign | cosign |
| SBOM upload | F3 | ✅ manual | `oss/sbom-upload.yml` | Dependency-Track | — |
| DAST | D1 | ✅ manual | `dast*.yml` | OWASP ZAP docker | ZAP action |
| **API fuzz** | D1 | ✅ manual | `api-fuzz-schemathesis.*` | Schemathesis docker | Schemathesis |
| **Binary fuzz** | QA | ✅ manual | `binary-fuzz.*` | AFL++ / Go / Jazzer | same |
| Sec func tests | D2 | ✅ | `sec-func-tests.*` | pytest stub | pytest stub |
| IAST | F1 | 🔧 stub | `iast-preprod.*` | **excluded** | commercial stub |
| Pentest gate | D3 | 📋 | [release-gate-checklist.md](../../docs/release-gate-checklist.md) | checklist | checklist |
| Conftest admission | E1 | ✅ | `conftest-admission.*` | Conftest docker | same |
| Helm deploy | D/E | ✅ manual | `oss/helm-deploy.yml` | Helm | deploy-preprod stub |
| K8s admission | E1 | 📋 | `templates/k8s/admission/` | Kyverno/OPA YAML | same |
| Network policy | E2 | 📋 | `templates/k8s/network/` | NetworkPolicy | same |
| Falco / CWPP | E3 | 📋 | `templates/k8s/runtime/` | Falco helm values | same |
| SIEM export | E4 | 📋 | phase E4 doc | Falco → SIEM | same |
| **WAF / API Sec** | F2 | 📋 **no CI** | [F2-rasp-waf.md](../../docs/phases/F2-rasp-waf.md) | runbook | runbook |
| **RASP** | F2 | 📋 **no CI** | [F2-rasp-waf.md](../../docs/phases/F2-rasp-waf.md) | runbook + SIEM | runbook |
| SBOM monitor | F3 | 📋 | [F3-advanced.md](../../docs/phases/F3-advanced.md) | DTrack + policy | doc |
| Fuzzing (API) | QA | ✅ manual | `api-fuzz-schemathesis.*` | Schemathesis | Schemathesis |
| Fuzzing (binary) | QA | ✅ manual | `binary-fuzz.*` | AFL++, Go, Jazzer | same |
| ASTO | all | ✅ | `aspm-export.py`, `.aspm_export` | DefectDojo | DefectDojo |
| AI/ML scans | opt | ✅ | `skill-scanner`, `ml-*` | profile `ai-ml` | profile `ai-ml` |

**Important:** RASP, WAF, cloud L7 WAF, and most commercial IAST are **prod/runtime** — not pipeline gates (AGENTS.md rule #4). Evidence = runbooks + SIEM, not SARIF in MR.

---

## Runtime & edge (RASP, WAF, IAST) — tools

| Class | OSS (catalog) | Commercial | In this template |
|-------|---------------|------------|------------------|
| **RASP** | OpenRASP, Falco (syscall) | Contrast, Sqreen, Imperva | 📋 F2 runbook; Falco in `k8s/runtime/` |
| **WAF / API** | ModSecurity, OWASP CRS | Cloud WAF, Kong, 42Crunch, Gravitee | 📋 F2 runbook; policies in Git |
| **IAST** | — | Contrast, Seeker, CxIAST | 🔧 `iast-preprod.*` stub (`full` only) |
| **Passive DAST** | — | — | F3 doc (prod monitoring) |

More names: supplement §RASP, §API Security, §DAST (Nuclei, StackHawk, …).

---

## Profiles (which stack)

| Profile | Scanners | D–F |
|---------|----------|-----|
| `minimal` | — | — |
| `shift-left` | vendor or mixed | — |
| `supply-chain` | + SBOM/sign | — |
| `full` | GitLab Security / CodeQL | DAST, IAST stub, **no RASP CI** |
| **`oss-full`** | 100% OSS docker/pip pins | DAST ZAP, Schemathesis, **binary fuzz**, conftest, Falco-ready K8s, **no IAST** |
| `ai-ml` | + skill/MCP/ML jobs | optional |

Adopt: `scripts/adopt.sh --profile oss-full|full --platform gitlab|github`

---

## ASPM export (oss-full)

```bash
python3 scripts/aspm-export.py --control sast --report semgrep.sarif
```

- GitLab: `.gitlab/jobs/aspm/export-after-script.yml`
- GitHub: `.github/actions/gate-and-export`
- Runbook: [aspm-export.md](../../docs/runbooks/aspm-export.md)

---

## Agent actions

1. **MR/shift-left tool** → row in table above → copy job from `templates/gitlab/jobs/` or `templates/github/workflows/`
2. **RASP/WAF/IAST prod** → read F2/F1 phases; do **not** add CI job without user license + explicit request
3. **New OSS scanner** → pin in `config/oss-tool-versions.yaml`, `python3 scripts/generate-oss-pins.py`, docker-only (no tarball)
4. **Commercial tool pick** → [04-tooling-catalog.md](../../docs/04-tooling-catalog.md) + supplement; note license in PR

Extended lists: [reference.md](reference.md)
