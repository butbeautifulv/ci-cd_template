---
name: devsecops-tooling
description: >-
  DevSecOps tool catalog by security class (SAST, SCA, DAST, IAST, RASP, WAF,
  MAST, ASPM). Use when selecting scanners, writing 04-tooling-catalog.md,
  or picking GitLab vs GitHub defaults.
---

# DevSecOps tooling catalog

Source: `docs/references/extracts/tools-map-pdf.txt`

Repo: `docs/04-tooling-catalog.md`, `config/security-gate-policy.yaml`, `config/aspm-export.yaml`.

## ASPM export (oss-full)

```bash
python3 scripts/aspm-export.py --control sast --report semgrep.sarif
```

- Config: `config/aspm-export.yaml` — control → DefectDojo `scan_type`
- GitLab: `.gitlab/jobs/aspm/export-after-script.yml` (per-scan `after_script`)
- Requires: `DEFECTDOJO_URL`, `DEFECTDOJO_API_TOKEN`
- Runbook: `docs/runbooks/aspm-export.md`

Tier: **builtin** (platform), **oss**, **commercial**.

## Template defaults

| Control | GitLab | GitHub | GitHub oss-full |
|---------|--------|--------|-----------------|
| SAST | SAST template | CodeQL | Semgrep docker pin |
| Linters | Code-Quality / custom | language linters | Ruff pin |
| Secrets | Secret Detection | Gitleaks action | Gitleaks tarball |
| SCA | Dependency Scanning | dependency-review + Trivy fs | Trivy tarball fs/image |
| IaC | IaC Scanning | Checkov action | Checkov pip pin |
| Container | Container Scanning | Trivy action | Trivy image tarball |
| DAST | DAST (license) | ZAP action | ZAP docker pin |
| ASPM | DefectDojo (`aspm-export.py`) | SARIF → DefectDojo | same |
| Registry | GitLab CR / Nexus | ghcr.io / Nexus | `oss/build-push.yml` |

GitHub oss-full: [docs/platforms/github-oss-full.md](../../docs/platforms/github-oss-full.md)

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
