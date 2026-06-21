# GitHub OSS Full Pipeline (`oss-full`)

**Shared reference:** [oss-full-shared.md](oss-full-shared.md) (pins, gates, registry, ASPM, validation, platform asymmetry).

Profile for **GitHub Actions** with 100% OSS scanners — no CodeQL, no `dependency-review`.

```bash
./scripts/adopt.sh --profile oss-full --platform github --target .
```

See also: [gitlab-oss-full.md](gitlab-oss-full.md) (GitLab CE equivalent).

## Pipeline flow

```
PR:  validate (lint + unit-test) → security-gates-oss (parallel OSS scans)
main: + build-push (GHCR) → sbom → sca-image → sign
```

Manual: `dast-oss.yml` (workflow_dispatch), `nightly-sast-oss.yml` (schedule).

## GitHub-specific workflows

| Job | Tool | Workflow |
|-----|------|----------|
| `secrets` | Gitleaks docker | `jobs/oss/gitleaks.yml` |
| `sast` | Semgrep docker | `jobs/oss/semgrep-sast.yml` |
| `osa` | Trivy docker (`aquasec/trivy`) | `jobs/oss/trivy-osa.yml` |
| `iac` | Checkov pip pin | `jobs/oss/checkov-iac.yml` |
| `dockerfile` | Hadolint docker | `jobs/oss/dockerfile-lint.yml` |
| `linters` | Ruff pip pin | `jobs/oss/linter-security.yml` |
| `forbidden` | find + gate | `jobs/oss/forbidden-files.yml` |
| `build` | docker build-push | `oss/build-push.yml` |
| `sbom` | Syft docker | `jobs/sbom-oss.yml` |
| `sca-image` | Trivy image | `oss/sca-image.yml` |
| `sign` | cosign | `jobs/sign-oss.yml` |
| `conftest` | OPA Conftest docker | `jobs/oss/conftest-admission.yml` |
| `sbom-upload` | Dependency-Track | `jobs/oss/sbom-upload.yml` (optional) |

Orchestrator: `security-gates-oss.yml`  
Optional: `dast-oss.yml` (workflow_dispatch), `nightly-sast-oss.yml` (schedule)

## Required permissions

```yaml
permissions:
  contents: read
  security-events: write
  packages: write
  id-token: write
```

Repository Settings → Actions → Workflow permissions: **Read and write**.

## Environment variables

Profile `env:` is generated from [`config/oss-tool-versions.yaml`](../../config/oss-tool-versions.yaml). Reference copy: [`config/github-oss-env.yml`](../../config/github-oss-env.yml).

| Variable | Purpose |
|----------|---------|
| `REGISTRY` | `ghcr.io/${{ github.repository }}` |
| `ENABLE_REAL_LINTERS` | `true` — Ruff gate |
| `OSS_*` | Scanner pins (see manifest) |

## Validation

```bash
bash scripts/validate-github-oss.sh
bash scripts/validate-pin-sync.sh
./scripts/adopt.sh --profile oss-full --platform github --target /tmp/oss-test --dry-run
```
