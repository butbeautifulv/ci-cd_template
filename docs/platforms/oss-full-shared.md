# OSS Full Profile — Shared Reference

Common content for GitLab and GitHub **`oss-full`** profiles. Platform deltas: [gitlab-oss-full.md](gitlab-oss-full.md), [github-oss-full.md](github-oss-full.md).

## Purpose

**100% open-source** DevSecOps pipeline — scope B–F with pinned OSS scanners (no GitLab Ultimate, CodeQL, or commercial-only agents by default).

All scanner **runtimes** come from **pinned container images** in [`config/oss-tool-versions.yaml`](../../config/oss-tool-versions.yaml) (no tarball curl, no `:latest`).

```bash
./scripts/adopt.sh --profile oss-full --platform gitlab|github --target .
```

## Full OSS stack by phase

| Phase | Control | OSS tool | Image / install | GitLab job | GitHub workflow |
|-------|---------|----------|-----------------|------------|-----------------|
| B1 | Secrets | Gitleaks | `ghcr.io/gitleaks/gitleaks` | `gitleaks-scan` | `jobs/oss/gitleaks.yml` |
| B1+ | Forbidden files | shell `find` + gate | — | `forbidden-files` | `jobs/oss/forbidden-files.yml` |
| B2 | SAST | Semgrep | `returntocorp/semgrep` | `semgrep-sast` | `jobs/oss/semgrep-sast.yml` |
| B3 | OSA | Trivy fs | `aquasec/trivy` | `trivy-osa` | `jobs/oss/trivy-osa.yml` |
| B4 | IaC | Checkov | pip pin | `checkov-iac` | `jobs/oss/checkov-iac.yml` |
| B5 | Dockerfile | Hadolint | `hadolint/hadolint` | `dockerfile-lint` | `jobs/oss/dockerfile-lint.yml` |
| B6 | Linters | Ruff | pip pin | `linter-security` | `jobs/oss/linter-security.yml` |
| C1 | SBOM | Syft | `anchore/syft` | `sbom-generate` | `jobs/sbom-oss.yml` |
| C2 | SCA image | Trivy image | `aquasec/trivy` | `trivy-sca` | `oss/sca-image.yml` |
| C3 | Registry | Nexus/Harbor/GHCR | config | `build-push` | `oss/build-push.yml` |
| C4 | Sign | cosign | GHA installer pin | `sign-image` | `jobs/sign-oss.yml` |
| C4+ | SBOM monitor | Dependency-Track | REST API | `sbom-upload` (manual) | `jobs/oss/sbom-upload.yml` |
| D1 | DAST | OWASP ZAP | `ghcr.io/zaproxy/zaproxy` | `dast-zap` (manual) | `dast-oss.yml` |
| D1 | DAST (Compose) | ZAP on localhost | same | `dast-compose` (manual) | `dast-compose-oss.yml` |
| D1 | API fuzz | Schemathesis | `ghcr.io/schemathesis/schemathesis` | `api-fuzz-schemathesis` (manual) | `api-fuzz-oss.yml` |
| QA | Binary fuzz | AFL++, Go, Jazzer | pinned docker images | `binary-fuzz` (manual) | `binary-fuzz-oss.yml` |
| D2 | Sec func tests | pytest | python | `sec-func-tests` | `jobs/sec-func-tests.yml` |
| F1 | IAST (runtime) | ZAP Full Scan | `ghcr.io/zaproxy/zaproxy` | `iast-preprod` (manual) | `iast-oss.yml` / job |
| E1 | Admission | Conftest/OPA | `openpolicyagent/conftest` | `conftest-admission` | `jobs/oss/conftest-admission.yml` |
| E2 | Deploy | Helm + kubectl | `alpine/helm` | `helm-deploy` | `oss/helm-deploy.yml` |
| F3 | Nightly SAST | Semgrep auto | `returntocorp/semgrep` | schedule job | `nightly-sast-oss.yml` |
| F3 | ASPM | DefectDojo | self-hosted API | upload waves `aspm/upload-*.yml` | `gate-and-export` action |

### Explicitly OSS-only (not in CI job)

| Class | OSS examples (catalog) | Notes |
|-------|------------------------|-------|
| Fuzzing | AFL++, Jazzer, go-fuzz | **Schemathesis** (API) + **AFL++/Go/Jazzer** (binary) in CI |
| DAST alt | Nuclei | supplement catalog |
| Runtime | Falco, Kyverno, OPA | K8s templates `templates/k8s/` — **runbook/K8s, не CI gate** |
| RASP / WAF | OpenRASP, ModSecurity, cloud WAF | F2 runbook only |
| MAST | MobSF | mobile appendix |
| ASPM | DefectDojo (default) | Phoenix/OX — commercial |

Profile `full` adds: CodeQL, GitLab Security templates, commercial IAST agents (optional overlay on F1).

## Version pinning

Single source: [`config/oss-tool-versions.yaml`](../../config/oss-tool-versions.yaml)

```bash
python3 scripts/generate-oss-pins.py
bash scripts/validate-pin-sync.sh
bash scripts/validate-oss-pins.sh
```

Runbook: [runbooks/oss-tool-pinning.md](../runbooks/oss-tool-pinning.md)

## Gate policy

[`config/security-gate-policy.yaml`](../../config/security-gate-policy.yaml) + [`scripts/gate-check.py`](../../scripts/gate-check.py)

## Platform asymmetry

| Feature | GitLab CE | GitHub |
|---------|-----------|--------|
| Scope B–F | full OSS stack | full OSS stack |
| Manual preprod scans | manual **jobs** in pipeline | manual **jobs** + `workflow_dispatch` workflows |
| Helm deploy | `helm-deploy` job | `oss/helm-deploy.yml` workflow |
| Nightly SAST | CI schedule | cron workflow |
| Registry default | GitLab Container Registry | GHCR |

## Validation

```bash
bash scripts/validate-yaml.sh
bash scripts/validate-github-oss.sh
bash scripts/validate-gitlab-oss.sh
./scripts/adopt.sh --profile oss-full --platform gitlab --target /tmp/t --dry-run
./scripts/adopt.sh --profile oss-full --platform github --target /tmp/t --dry-run
./scripts/adopt.sh --profile oss-full-node --platform github --target /tmp/t --dry-run
```

**Node/TypeScript apps (no Ruff/pytest):** profile `oss-full-node` — [github-oss-full-node.md](github-oss-full-node.md).  
**GitLab enterprise (Kaniko+Helm):** profile `oss-full-enterprise` — [gitlab-enterprise-deploy.md](../references/supplements/gitlab-enterprise-deploy.md).  
**Real adoption case studies:** [fstec-adaptation-case-study.md](../references/supplements/fstec-adaptation-case-study.md), [common-templates-adaptation-case-study.md](../references/supplements/common-templates-adaptation-case-study.md).

### DAST URL variables

| Variable | Platform | Behavior |
|----------|----------|----------|
| `PREPROD_URL` | GitLab/GitHub | Default preprod target; opt-in DAST when not placeholder |
| `DAST_WEBSITE` | GitLab (alias) | Same as common-templates — auto-runs DAST when set |
| `DAST_COMPOSE_ENABLED` | GitLab | Auto-runs `dast-compose` on main when `true` |

### Security kill-switch

Set `SAST_DISABLED=true` or `SECURITY_DISABLED=true` to skip all security scan and ASPM upload jobs.

## vs profile `full`

| | `full` | `oss-full` |
|---|--------|------------|
| Scope | B–F | B–F (полный OSS) |
| Scanners | Vendor templates / CodeQL | Gitleaks, Semgrep, Trivy, Checkov, … |
| F1 IAST | ZAP Full Scan (+ optional commercial agent) | ZAP Full Scan |
| RASP/WAF | runbook F2 | runbook F2 |
| Supply chain | mixed pins | manifest + docker-only scanners |
