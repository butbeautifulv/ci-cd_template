# Каталог инструментов DevSecOps

По классам из «Карты инструментов DevSecOps» (PDF). Tier: **builtin** (платформа), **oss**, **commercial**.

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

## Fuzzing / concolic / sanitizers

| Класс | Примеры |
|-------|---------|
| Fuzzing | AFL++, libFuzzer, Jazzer, go-fuzz, Honggfuzz |
| Concolic | спец. движки под язык |
| Sanitizers | ASan, MSan, UBSan, Valgrind |
| Coverage | llvm-cov, gcov + интеграция с DAST |

Документируются в QA-зоне; отдельные CI jobs — по запросу (не в базовом B-фазе).

## MAST (mobile)

| Tier | Примеры |
|------|---------|
| oss | MobSF, QARK, Androbugs |
| commercial | NowSecure, Guardsquare |

## IAST

| Tier | Примеры |
|------|---------|
| commercial | Contrast Assess, Synopsys Seeker, Checkmarx CxIAST, Hdiv, Veracode Interactive |

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
| oss | Falco, OPA Gatekeeper, Kyverno, kube-bench, kube-hunter |
| commercial | Aqua, Sysdig, Prisma Cloud, NeuVector |

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

| Контроль | GitLab default | GitHub default |
|----------|----------------|----------------|
| SAST | SAST template | CodeQL |
| Linters | Code-Quality / custom | super-linter / language linters |
| Secrets | Secret-Detection | Gitleaks action |
| SCA | Dependency-Scanning | dependency-review + Trivy fs (→ **OSA**) |
| SCA image | Container Scanning | Trivy image (→ **SCA** post-SBOM) |
| IaC | IaC-Scanning | Checkov action |
| Container | Container-Scanning | Trivy action |
| DAST | DAST template (license) | ZAP action |
| ASPM | DefectDojo (self-hosted) | DefectDojo / SARIF upload |

См. [platforms/](platforms/).

## Extended catalog (supplement)

Полный OCR-список инструментов (commercial + niche OSS): [supplements/devsecops_tools.md](references/supplements/devsecops_tools.md).

Registry и artifact storage: [runbooks/nexus-docker-registry.md](runbooks/nexus-docker-registry.md), phase [C3-registry.md](phases/C3-registry.md).
