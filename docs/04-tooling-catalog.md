# Каталог инструментов DevSecOps

По классам из «Карты инструментов DevSecOps» (PDF). Tier: **builtin** (платформа), **oss**, **commercial**.

Матрица CI vs runtime: [03-security-controls.md](03-security-controls.md). Job-лист `oss-full`: [platforms/oss-full-shared.md](platforms/oss-full-shared.md). Пины образов: [config/oss-tool-versions.yaml](../config/oss-tool-versions.yaml).

## SAST

| Tier | Примеры |
|------|---------|
| builtin | GitLab SAST, GitHub CodeQL |
| oss | Semgrep, Bandit, Checkov (multi), tfsec, njsscan, bearer, Brakeman |
| commercial | SonarQube EE, Checkmarx, Fortify, PT Application Inspector, Coverity, Klocwork |

**Рекомендация шаблона:** GitLab SAST / CodeQL + Semgrep OSS для кастомных правил.

**Profile `oss-full`:** jobs under `.gitlab/jobs/oss/` — Gitleaks, Semgrep, Trivy (fs+image), Checkov, Hadolint, Ruff; all scanner runtimes via **pinned Docker images** (see [platforms/oss-full-shared.md](platforms/oss-full-shared.md)).

## Linters (security gate)

| Tier | Примеры |
|------|---------|
| oss | ESLint security plugins, golangci-lint, Ruff/Bandit (Python), shellcheck |
| builtin | GitLab Code-Quality (частично) |

Линтеры — отдельный компонент Security Gate на MR (финтех-PDF).

## Secret detection

| Tier | Примеры |
|------|---------|
| builtin | GitLab Secret Detection |
| oss | Gitleaks, detect-secrets, git-secrets, TruffleHog |
| commercial | GitGuardian |

**Profile `oss-full`:** job `gitleaks-scan` (`.gitlab/jobs/oss/gitleaks.yml`).

## OSA / SCA split (DAF)

| Control | Stage | Target | Policy key | oss-full job |
|---------|-------|--------|------------|--------------|
| **OSA** | MR / Code | Manifests | `osa:` | `trivy-osa` |
| **SCA** | Build post-SBOM | Container image | `sca:` | `trivy-sca` |

## OSA / SCA / SBOM

| Tier | Примеры |
|------|---------|
| builtin | GitLab Dependency Scanning, GitHub dependency-review |
| oss | Trivy (fs), Grype, Dependency-Track, Syft, CycloneDX CLI |
| commercial | Snyk, JFrog Xray, Mend, Black Duck, FOSSA, CodeScoring |

## IaC scan

| Tier | Примеры |
|------|---------|
| builtin | GitLab IaC Scanning |
| oss | Checkov, tfsec, kics, Terrascan, kube-score |
| commercial | — |

## Container / image

| Tier | Примеры |
|------|---------|
| builtin | GitLab Container Scanning |
| oss | Trivy, Grype, Clair, Dockle |
| commercial | Aqua, Prisma Cloud, Qualys |

## Dockerfile / Dock (JCSF)

Hadolint, Checkov dockerfile, Dockle — см. `T-CODE-DOCKERFS`, JCSF **Dock**.

## DAST

| Tier | Примеры |
|------|---------|
| oss | OWASP ZAP, Codename SCNR (Arachni) |
| commercial | Burp Suite EE, Acunetix, PT Black Box, HCL AppScan, Netsparker |

**В шаблоне:** ZAP baseline — `dast.yml` / `dast-oss.yml` (manual preprod). Gate: `dast:` в [security-gate-policy.yaml](../config/security-gate-policy.yaml).

## Fuzzing / concolic / sanitizers

| Класс | Примеры |
|-------|---------|
| **API fuzz (OpenAPI)** | **Schemathesis** |
| **Binary fuzz** | AFL++, Go `-fuzz`, Jazzer, libFuzzer, go-fuzz, Honggfuzz |
| Concolic | Sydr, спец. движки под язык |
| Sanitizers | ASan, MSan, UBSan, Valgrind |
| Coverage | llvm-cov, gcov + интеграция с DAST |

**В шаблоне (CI, manual QA/preprod):**

| Контроль | Job / workflow | OSS pin (manifest) | Gate key |
|----------|----------------|--------------------|----------|
| API fuzz | `api-fuzz-schemathesis.yml`, `api-fuzz-oss.yml` | `ghcr.io/schemathesis/schemathesis:4.21.7` | `fuzzing` |
| Binary fuzz | `binary-fuzz.yml`, `binary-fuzz-oss.yml` | AFL++ `v4.40c`, Go `1.23.8`, Maven+Jazzer `0.24.0` | `binary_fuzz` |

Orchestrator: [`scripts/run-binary-fuzz.sh`](../scripts/run-binary-fuzz.sh). Примеры: `examples/fuzzing/{c,go,java}/`, OpenAPI: `examples/openapi/minimal.yaml`.

Sanitizers/concolic — QA-зона, без CI job по умолчанию (ASan через AFL++ harness опционально).

## MAST (mobile)

| Tier | Примеры |
|------|---------|
| oss | MobSF, QARK, Androbugs |
| commercial | NowSecure, Guardsquare |

## IAST

| Tier | Примеры |
|------|---------|
| oss | **OWASP ZAP Full Scan** (active runtime / spider), Schemathesis (API runtime) |
| commercial | Contrast Assess, Synopsys Seeker, Checkmarx CxIAST, Hdiv, Veracode Interactive |

**В шаблоне:** OSS F1 — `iast-preprod.yml` / `iast-oss.yml` (ZAP full scan, manual preprod). Commercial agents — optional overlay, см. [phases/F1-iast.md](phases/F1-iast.md).

## RASP

| Tier | Примеры |
|------|---------|
| oss | OpenRASP, **Falco** (K8s runtime — см. [phases/E3-falco.md](phases/E3-falco.md)) |
| commercial | Contrast (runtime), Sqreen, Imperva, Appdome |

**В шаблоне:** не CI job — [phases/F2-rasp-waf.md](phases/F2-rasp-waf.md), SIEM correlation E4. Supplement: OpenRASP, Liapp, …

## WAF / API Sec

| Tier | Примеры |
|------|---------|
| oss | ModSecurity, OWASP CRS |
| commercial | Cloud WAF, Kong/Apigee, Salt Security, **42Crunch**, Gravitee |

**В шаблоне:** не CI job — F2 runbook; API policies in Git. Supplement: WSO2, QAPISec, Probely, …

## BCA / binary

| Tier | Примеры |
|------|---------|
| oss | Ghidra, JADX, ILSpy, radare2 |
| commercial | Binary Ninja, IDA Pro |

## Runtime K8s

| Tier | Примеры |
|------|---------|
| oss | Falco, OPA Gatekeeper, Kyverno, kube-bench, kube-hunter, **Conftest** (policy) |
| commercial | Aqua, Sysdig, Prisma Cloud, NeuVector |

**В шаблоне:** admission YAML — `templates/k8s/admission/`; Conftest job — `conftest-admission.yml` (oss-full); Falco — `templates/k8s/runtime/`, [phases/E3-falco.md](phases/E3-falco.md).

## ASPM / ASTO / оркестрация findings

| Tier | Примеры |
|------|---------|
| oss | DefectDojo |
| commercial | AppSec.Track, CodeScoring, Jit, ArmorCode, Brinqa |

**ASTO** — агрегатор уязвимостей из SAST/DAST/SCA (финтех-PDF); SARIF — точка интеграции.

Template: [`scripts/aspm-export.py`](../scripts/aspm-export.py) + [`config/aspm-export.yaml`](../config/aspm-export.yaml) → DefectDojo `import-scan` / `reimport-scan`.

## Codec / обфускация (PDF)

ProGuard, DexGuard — для mobile; вне scope базового шаблона.

## Taint analysis

Коммерческие и исследовательские taint tools — для SecChamp на этапе дизайна (не CI job по умолчанию).

## Выбор для шаблона

| Контроль | GitLab default | GitHub default | Profile `oss-full` |
|----------|----------------|----------------|---------------------|
| SAST | SAST template | CodeQL | Semgrep (docker pin) |
| Linters | Code-Quality / custom | super-linter / language linters | Ruff (pip pin) |
| Secrets | Secret-Detection | Gitleaks action | Gitleaks (docker pin) |
| Forbidden files | — | — | shell + gate |
| OSA | Dependency-Scanning | dependency-review + Trivy fs | Trivy fs |
| SCA image | Container Scanning | Trivy image | Trivy image |
| IaC | IaC-Scanning | Checkov action | Checkov (pip pin) |
| Dockerfile | — | hadolint-action | Hadolint (docker pin) |
| SBOM / sign | — | Syft / cosign | Syft / cosign |
| DAST | DAST template (license) | ZAP action | ZAP (docker pin, manual) |
| API fuzz | — | — | Schemathesis (manual) |
| Binary fuzz | — | — | AFL++ / Go / Jazzer (manual) |
| Sec func tests | custom | pytest + `tests/security/` | pytest + `tests/security/` |
| IAST | — | ZAP Full Scan (manual) | ZAP Full Scan (manual) |
| Admission | — | — | Conftest (docker pin) |
| ASPM | DefectDojo (self-hosted) | DefectDojo / SARIF upload | DefectDojo via `aspm-export.py` |
| RASP / WAF | — | — | runbook F2 only |

См. [platforms/](platforms/).

## Extended catalog (supplement)

Полный OCR-список инструментов (commercial + niche OSS): [supplements/devsecops_tools.md](references/supplements/devsecops_tools.md).

Registry и artifact storage: [runbooks/nexus-docker-registry.md](runbooks/nexus-docker-registry.md), phase [C3-registry.md](phases/C3-registry.md).
