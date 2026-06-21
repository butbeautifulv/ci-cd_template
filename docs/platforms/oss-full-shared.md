# OSS Full Profile — Shared Reference

Common content for GitLab and GitHub **`oss-full`** profiles. Platform-specific deltas: [gitlab-oss-full.md](gitlab-oss-full.md), [github-oss-full.md](github-oss-full.md).

## Purpose

100% open-source scanners with **semver-pinned** tools — no GitLab Ultimate templates, no CodeQL, no `dependency-review`, no rolling `:latest` tags.

Adopt:

```bash
./scripts/adopt.sh --profile oss-full --platform gitlab|github --target .
```

## OSS stack (logical)

| Control | Tool | Gate |
|---------|------|------|
| B1 Secrets | Gitleaks | warn → block (policy) |
| B2 SAST | Semgrep | block critical/high |
| B3 OSA | Trivy fs | block critical (MR) |
| B4 IaC | Checkov | block critical/high |
| B5 Dockerfile | Hadolint | warn |
| B6 Linters | Ruff | warn |
| C1 SBOM | Syft | required on main |
| C2 SCA image | Trivy image | block critical/high |
| C4 Sign | cosign | manual / keyless |

## Version pinning

Single source of truth: [`config/oss-tool-versions.yaml`](../../config/oss-tool-versions.yaml)

Generated mirrors (do not edit by hand):

| Target | Purpose |
|--------|---------|
| `templates/gitlab/jobs/oss/versions.yml` | GitLab `OSS_*` variables |
| `config/github-oss-env.yml` | GitHub env reference |
| `templates/profiles/oss-full.github.yml` | Profile `env:` block |

Update workflow:

```bash
# 1. Edit config/oss-tool-versions.yaml
python3 scripts/generate-oss-pins.py
bash scripts/validate-pin-sync.sh
bash scripts/validate-oss-pins.sh
```

Runbook: [runbooks/oss-tool-pinning.md](../runbooks/oss-tool-pinning.md)  
Incident: [references/supply-chain-teampcp-2026.md](../references/supply-chain-teampcp-2026.md)

## Gate policy

[`config/security-gate-policy.yaml`](../../config/security-gate-policy.yaml) + [`scripts/gate-check.py`](../../scripts/gate-check.py) — shared on both platforms.

- **OSA** (MR): block critical in direct deps
- **SCA** (image): block critical/high
- SAST/IaC: block critical/high
- Secrets/dockerfile/linters/DAST: warn
- SBOM: required on main

`ENABLE_REAL_LINTERS=true` by default in oss-full.

## External registry (Nexus / Harbor / Artifactory)

Manifest: [`config/artifact-registry.yaml`](../../config/artifact-registry.yaml)  
Runbook: [runbooks/nexus-docker-registry.md](../runbooks/nexus-docker-registry.md)

Set `REGISTRY_BACKEND`, `REGISTRY_HOST`, `REGISTRY_REPOSITORY`, `REGISTRY_USER`, `REGISTRY_PASSWORD`.

## DefectDojo (ASPM export)

- Config: [`config/aspm-export.yaml`](../../config/aspm-export.yaml)
- CLI: [`scripts/aspm-export.py`](../../scripts/aspm-export.py)
- Runbook: [runbooks/aspm-export.md](../runbooks/aspm-export.md)

GitLab: `.aspm_export` after_script snippet. GitHub: composite action `gate-and-export`.

## Platform asymmetry

| Feature | GitLab oss-full | GitHub oss-full |
|---------|-----------------|-----------------|
| Orchestration | GitLab `include:` stages | Reusable `workflow_call` |
| Post-build deploy | Helm preprod/prod (manual) | GHCR push only; no Helm in profile |
| DAST | Manual job + ZAP docker | `dast-oss.yml` workflow_dispatch |
| SBOM upload | Dependency-Track (manual) | Artifact upload only |
| Admission test | Conftest job | Not in profile |
| Nightly SAST | Scheduled Semgrep | `nightly-sast-oss.yml` |
| ASPM hook | Single `.aspm_export` YAML anchor | `.github/actions/gate-and-export` |

Both platforms enforce the same SARIF report names and gate contract.

## Validation

```bash
bash scripts/validate-yaml.sh
bash scripts/validate-pin-sync.sh
bash scripts/validate-oss-pins.sh
bash scripts/validate-github-oss.sh
./scripts/adopt.sh --profile oss-full --platform gitlab --target /tmp/t --dry-run
./scripts/adopt.sh --profile oss-full --platform github --target /tmp/t --dry-run
```

## Differences from profile `full`

| | `full` | `oss-full` |
|---|--------|------------|
| Scanners | Platform vendor templates / CodeQL | Gitleaks, Semgrep, Trivy, Checkov |
| Pin policy | Mixed | Manifest-enforced |
| License | GitLab Ultimate / GH Advanced Security optional | OSS only |
