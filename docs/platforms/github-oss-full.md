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
| `secrets` | Gitleaks docker | inline in `security-gates-oss.yml` |
| `sast` | Semgrep docker | inline in `security-gates-oss.yml` |
| `osa` | Trivy docker (`aquasec/trivy`) | inline in `security-gates-oss.yml` |
| `iac` | Checkov pip pin | inline in `security-gates-oss.yml` |
| `dockerfile` | Hadolint docker | inline in `security-gates-oss.yml` |
| `linters` | Ruff pip pin (Python projects) | inline in `security-gates-oss.yml` |
| `forbidden` | find + gate | inline in `security-gates-oss.yml` |
| `build` | docker build-push | `oss/build-push.yml` |
| `sbom` | Syft docker | `jobs/sbom-oss.yml` |
| `sca-image` | Trivy image | `oss/sca-image.yml` |
| `sign` | cosign | `jobs/sign-oss.yml` |
| `conftest` | OPA Conftest docker | `jobs/oss/conftest-admission.yml` |
| `sbom-upload` | Dependency-Track | `jobs/oss/sbom-upload.yml` (optional) |

Orchestrator: `security-gates-oss.yml` (**inline jobs** — GitHub rejects reusable workflows under `workflows/jobs/`).  
Reference copies for copy-paste: `jobs/oss/*.yml`.  
Node/TypeScript stack: profile [`oss-full-node`](github-oss-full-node.md).  
Case study: [fstec-adaptation-case-study.md](../references/supplements/fstec-adaptation-case-study.md).

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
