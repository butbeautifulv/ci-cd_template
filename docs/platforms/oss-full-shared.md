# OSS Full Profile — Shared Reference

Common content for GitLab and GitHub **`oss-full`** profiles. Platform deltas: [gitlab-oss-full.md](gitlab-oss-full.md), [github-oss-full.md](github-oss-full.md).

## Purpose

**100% open-source** DevSecOps pipeline — equivalent scope to profile `full`, without GitLab Ultimate, CodeQL, `dependency-review`, or commercial scanners (IAST/RASP in CI).

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
| D1 | API fuzz | Schemathesis | `ghcr.io/schemathesis/schemathesis` | `api-fuzz-schemathesis` (manual) | `api-fuzz-oss.yml` |
| QA | Binary fuzz | AFL++, Go, Jazzer | pinned docker images | `binary-fuzz` (manual) | `binary-fuzz-oss.yml` |
| D2 | Sec func tests | pytest | python | `sec-func-tests` | `jobs/sec-func-tests.yml` |
| E1 | Admission | Conftest/OPA | `openpolicyagent/conftest` | `conftest-admission` | `jobs/oss/conftest-admission.yml` |
| E2 | Deploy | Helm + kubectl | `alpine/helm` | `helm-deploy` | — (GitLab only) |
| F3 | Nightly SAST | Semgrep auto | `returntocorp/semgrep` | schedule job | `nightly-sast-oss.yml` |
| F3 | ASPM | DefectDojo | self-hosted API | `.aspm_export` | `gate-and-export` action |

### Explicitly OSS-only (not in CI job)

| Class | OSS examples (catalog) | Notes |
|-------|------------------------|-------|
| Fuzzing | AFL++, Jazzer, go-fuzz | **Schemathesis** (API) + **AFL++/Go/Jazzer** (binary) in CI |
| DAST alt | Nuclei | supplement catalog |
| Runtime | Falco, Kyverno, OPA | K8s templates `templates/k8s/` |
| MAST | MobSF | mobile appendix |
| ASPM | DefectDojo (default) | Phoenix/OX — commercial |

Commercial-only in profile `full`: **IAST** (Contrast, Seeker), **CodeQL**, GitLab Security templates.

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

| Feature | GitLab | GitHub |
|---------|--------|--------|
| Helm deploy preprod/prod | yes (manual) | not in profile |
| DAST | manual job | `workflow_dispatch` |
| Nightly SAST | CI schedule | cron workflow |

## Validation

```bash
bash scripts/validate-yaml.sh
bash scripts/validate-github-oss.sh
./scripts/adopt.sh --profile oss-full --platform gitlab --target /tmp/t --dry-run
./scripts/adopt.sh --profile oss-full --platform github --target /tmp/t --dry-run
```

## vs profile `full`

| | `full` | `oss-full` |
|---|--------|------------|
| Scope | B–F incl. IAST stub | B–F minus IAST |
| Scanners | Vendor templates / CodeQL | Gitleaks, Semgrep, Trivy, Checkov, … |
| Supply chain | mixed pins | manifest + docker-only scanners |
