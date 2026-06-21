# GitHub OSS Full Pipeline (`oss-full`)

Profile for **GitHub Actions** with 100% open-source scanners — no CodeQL, no `dependency-review`.

Adopt:

```bash
./scripts/adopt.sh --profile oss-full --platform github --target .
```

See also: [gitlab-oss-full.md](gitlab-oss-full.md) (GitLab CE equivalent).

## Pipeline flow

```
PR:  lint → unit-test → security-gates-oss (parallel OSS scans)
main: + build-push (GHCR) → sbom → sca-image → sign
```

Manual: `dast-oss.yml` (workflow_dispatch), `nightly-sast-oss.yml` (schedule).

## OSS stack

| Job | Tool | Workflow |
|-----|------|----------|
| `secrets` | Gitleaks tarball | `jobs/oss/gitleaks.yml` |
| `sast` | Semgrep docker | `jobs/oss/semgrep-sast.yml` |
| `osa` | Trivy fs tarball | `jobs/oss/trivy-osa.yml` |
| `iac` | Checkov pip pin | `jobs/oss/checkov-iac.yml` |
| `dockerfile` | Hadolint docker | `jobs/oss/dockerfile-lint.yml` |
| `linters` | Ruff pip pin | `jobs/oss/linter-security.yml` |
| `build` | docker build-push | `oss/build-push.yml` |
| `sbom` | Syft docker | `jobs/sbom-oss.yml` |
| `sca-image` | Trivy image | `oss/sca-image.yml` |
| `sign` | cosign | `jobs/sign-oss.yml` |

Orchestrator: `security-gates-oss.yml`  
Entry: `templates/profiles/oss-full.github.yml` → `.github/workflows/ci.yml` on adopt

## Required permissions

```yaml
permissions:
  contents: read
  security-events: write
  packages: write    # GHCR push
  id-token: write    # cosign keyless
```

Repository Settings → Actions → General → Workflow permissions: **Read and write**.

## Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `REGISTRY` | `ghcr.io/${{ github.repository }}` | Image prefix |
| `ENABLE_REAL_LINTERS` | `true` | Ruff gate |
| `OSS_TRIVY_VERSION` | `0.63.0` | Trivy tarball (not trivy-action) |
| `OSS_GITLEAKS_VERSION` | `8.22.1` | Gitleaks release |
| `OSS_SEMGREP_IMAGE` | `returntocorp/semgrep:1.117.0` | Semgrep docker |

Full pin list: `config/github-oss-env.yaml` + `config/oss-tool-versions.yaml`

## External registry (Nexus)

Set repository **Variables**:

| Variable | Example |
|----------|---------|
| `REGISTRY_BACKEND` | `nexus` |
| `REGISTRY_HOST` | `nexus.example.com:8082/repository/docker-hosted` |
| `REGISTRY_REPOSITORY` | `myorg/myapp` |

Set **Secrets**: `REGISTRY_PASSWORD`  
See [runbooks/nexus-docker-registry.md](../runbooks/nexus-docker-registry.md)

## Optional: DefectDojo ASPM

Repository variable `DEFECTDOJO_URL` + secret `DEFECTDOJO_API_TOKEN` — each OSS job exports via `aspm-export.py`.

## Validation

```bash
bash scripts/validate-github-oss.sh
./scripts/adopt.sh --profile oss-full --platform github --target /tmp/oss-test --dry-run
```

## Differences from profile `full`

| | `full` | `oss-full` |
|---|--------|------------|
| SAST | CodeQL + semgrep-action | Semgrep docker only |
| OSA | dependency-review + trivy-action | Trivy fs tarball |
| Container | trivy-action | Trivy image tarball |
| Pins | mixed | manifest-enforced |
