---
name: devsecops-tooling
description: >-
  DevSecOps tool catalog by security class (SAST, SCA, DAST, IAST, RASP, WAF,
  MAST, ASPM). Use when selecting scanners, writing 04-tooling-catalog.md,
  or picking GitLab vs GitHub defaults.
---

# DevSecOps tooling catalog

Source: `.external/Карта инструментов DevSecOps.pdf`

Repo: `docs/04-tooling-catalog.md`, `config/security-gate-policy.yaml`.

Tier: **builtin** (platform), **oss**, **commercial**.

## Template defaults

| Control | GitLab | GitHub |
|---------|--------|--------|
| SAST | SAST template | CodeQL |
| Linters | Code-Quality / custom | language linters |
| Secrets | Secret Detection | Gitleaks |
| SCA | Dependency Scanning | dependency-review + Trivy fs |
| IaC | IaC Scanning | Checkov |
| Container | Container Scanning | Trivy |
| DAST | DAST (license) | ZAP action |
| ASPM | DefectDojo | SARIF → DefectDojo |

## Classes (summary)

| Class | OSS examples | Commercial |
|-------|--------------|------------|
| SAST | Semgrep, Bandit, Brakeman | Checkmarx, Fortify, Coverity |
| Secrets | Gitleaks, TruffleHog | GitGuardian |
| SCA/SBOM | Trivy, Syft, Grype, Dep-Track | Snyk, Black Duck |
| IaC | Checkov, tfsec, kics | — |
| Container | Trivy, Grype, Dockle | Aqua, Prisma |
| DAST | OWASP ZAP | Burp EE, Acunetix |
| Fuzzing | AFL++, Jazzer, go-fuzz | — |
| MAST | MobSF, QARK | NowSecure |
| IAST | — | Contrast, Seeker |
| RASP | — | Contrast, Sqreen |
| WAF/API | ModSecurity | Cloud WAF, Kong |
| Runtime K8s | Falco, Kyverno, OPA | Sysdig, Aqua |
| ASPM/ASTO | DefectDojo | Jit, ArmorCode |

Full tables: [reference.md](reference.md)

## Selection rules

1. Prefer **builtin** if license covers your org
2. Add **Semgrep** for custom rules alongside CodeQL/SAST
3. Single SARIF format for all scanners → ASTO
4. Do not add commercial tools to template without license note
