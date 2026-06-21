# GitLab OSS Full Pipeline (`oss-full`)

Profile for **GitLab CE / Self-hosted** without GitLab Ultimate Security templates. All scanners run as direct OSS Docker images or CLI installs.

Adopt:

```bash
./scripts/adopt.sh --profile oss-full --platform gitlab --target .
```

See also: [gitlab.md](gitlab.md) (GitLab Security templates profile `full`).

## Pipeline stages

```
validate → test → security → build → deploy → post-deploy
```

## OSS stack

| Job | Tool | Stage |
|-----|------|-------|
| `gitleaks-scan` | Gitleaks | security |
| `semgrep-sast` | Semgrep | security |
| `trivy-osa` | Trivy fs (manifests) | security |
| `checkov-iac` | Checkov | security (path-filtered) |
| `dockerfile-lint` | Hadolint | security |
| `linter-security` | Ruff | security |
| `build-image` | Docker build+push | build |
| `sbom-generate` | Syft | build |
| `trivy-sca` | Trivy image | build |
| `deploy-preprod` | Helm | deploy (manual) |
| `deploy-prod` | Helm | deploy (manual) |
| `sign-image` | cosign | post-deploy (manual) |
| `dast-zap` | OWASP ZAP | post-deploy (manual) |
| `sec-func-tests` | pytest | post-deploy |
| `conftest-admission` | Conftest | validate |
| `nightly-sast-scheduled` | Semgrep | schedule |
| `sbom-upload` | Dependency-Track | post-deploy (manual) |

Job files: `.gitlab/jobs/oss/`

## Required CI/CD variables

| Variable | Type | Purpose |
|----------|------|---------|
| `CI_REGISTRY_*` | builtin | Container Registry login (default backend `gitlab`) |
| `KUBECONFIG` | File, masked | kubectl/helm access to cluster |
| `PREPROD_URL` | Variable | DAST target after preprod deploy |
| `HELM_CHART_PATH` | Variable | Default `chart/` (copied on adopt) |
| `HELM_RELEASE` | Variable | Default `sample-app` |
| `NAMESPACE_PREPROD` | Variable | Default `preprod` |
| `NAMESPACE_PROD` | Variable | Default `prod` |

## Optional variables

| Variable | Purpose |
|----------|---------|
| `COSIGN_PRIVATE_KEY` | Keyed image signing (else keyless Sigstore) |
| `DTRACK_URL`, `DTRACK_API_KEY`, `DTRACK_PROJECT_UUID` | SBOM upload to Dependency-Track |
| `DEFECTDOJO_URL` | ASPM — enable DefectDojo export |
| `DEFECTDOJO_API_TOKEN` | API token (masked) |
| `DEFECTDOJO_PRODUCT_NAME` | Product name (default `$CI_PROJECT_NAME`) |
| `DEFECTDOJO_ENGAGEMENT` | Engagement name (default `CI/CD`) |
| `DEFECTDOJO_FAIL_ON_ERROR` | Fail job on upload error (default `false`) |
| `GITLEAKS_VERSION` | Override Gitleaks release (default from `OSS_GITLEAKS_VERSION` in `versions.yml`) |
| `REGISTRY_BACKEND` | `gitlab` (default), `nexus`, `harbor`, `artifactory`, `generic` |
| `REGISTRY_HOST`, `REGISTRY_USER`, `REGISTRY_PASSWORD` | External Docker registry (when backend ≠ gitlab) |
| `REGISTRY_REPOSITORY` | Image path suffix, e.g. `myorg/myapp` |

## External registry (Nexus / Harbor)

Default: images push to GitLab Container Registry (`REGISTRY_BACKEND=gitlab`).

For **Nexus**, **Harbor**, or **Artifactory**, set:

```yaml
REGISTRY_BACKEND: nexus
REGISTRY_HOST: nexus.example.com:8082/repository/docker-hosted
REGISTRY_REPOSITORY: myorg/myapp
REGISTRY_USER: ci-bot
REGISTRY_PASSWORD: <masked>
```

Manifest: `config/artifact-registry.yaml`  
Runbook: [runbooks/nexus-docker-registry.md](../runbooks/nexus-docker-registry.md)

Jobs using shared login: `build-image`, `trivy-sca`, `sign-image`.

## Version pinning

All OSS scanner images and CLI versions are **semver-pinned** — no `:latest`, `:stable`, or Trivy `install.sh@main`.

| Source | Purpose |
|--------|---------|
| `config/oss-tool-versions.yaml` | Manifest (docs + validation) |
| `.gitlab/jobs/oss/versions.yml` | GitLab `OSS_*` CI variables |

Runbook: [runbooks/oss-tool-pinning.md](../runbooks/oss-tool-pinning.md)  
Incident context: [references/supply-chain-teampcp-2026.md](../references/supply-chain-teampcp-2026.md)

```bash
bash scripts/validate-oss-pins.sh
```

## Kubernetes access

### Option A: KUBECONFIG file variable

1. Settings → CI/CD → Variables → Add `KUBECONFIG` (type: File, masked)
2. Paste kubeconfig with access to preprod/prod namespaces

### Option B: GitLab Agent for Kubernetes

1. Install [GitLab Agent](https://docs.gitlab.com/ee/user/clusters/agent/) in cluster
2. Use agent context in job `before_script`:

```yaml
before_script:
  - kubectl config use-context path/to/agent:connection
```

Document agent path per your GitLab project setup.

## Helm chart

On adopt, `templates/k8s/helm/sample-app/` is copied to `chart/` if missing.

Deploy sets image from CI:

```bash
helm upgrade --install sample-app chart/ \
  --namespace preprod \
  --set image.repository=$CI_REGISTRY_IMAGE \
  --set image.tag=$CI_COMMIT_SHA
```

## Gate policy

Same as other profiles: `config/security-gate-policy.yaml` + `scripts/gate-check.py`.

- **OSA** (MR): block critical in direct deps
- **SCA** (image): block critical/high
- SAST/IaC: **block** critical/high
- Secrets/dockerfile/linters/DAST: **warn**
- SBOM: **required** on main

`ENABLE_REAL_LINTERS=true` by default in `oss-full`.

## Validation (local)

```bash
bash scripts/validate-yaml.sh
python3 scripts/validate-policy.py
bash scripts/validate-oss-pins.sh
cd examples/sample-app
semgrep scan --config p/ci --sarif -o /tmp/semgrep.sarif .
python3 ../../scripts/gate-check.py --control sast --report /tmp/semgrep.sarif
```

## MR vs main

| Trigger | Jobs |
|---------|------|
| MR | gitleaks, semgrep, **trivy-osa**, checkov (if IaC changed), hadolint, linters, conftest |
| main | + build/push → sbom → **trivy-sca** (image); manual deploy/DAST/sign |

## Differences from profile `full`

| | `full` | `oss-full` |
|---|--------|------------|
| Scanners | GitLab `Security/*` templates | Gitleaks, Semgrep, Trivy, Checkov |
| GitLab Ultimate | Recommended for Scan Policies | Not required |
| Deploy | echo stub | Helm preprod/prod |
| IAST | stub job | excluded |

## DefectDojo (ASPM export)

Each scanner job uploads findings in `after_script` when `DEFECTDOJO_URL` is set.

- Config: `config/aspm-export.yaml`
- CLI: `scripts/aspm-export.py`
- Runbook: [runbooks/aspm-export.md](../runbooks/aspm-export.md)

```bash
# Local dry-run
export DEFECTDOJO_URL=https://defectdojo.example
python3 scripts/aspm-export.py --control sast --report semgrep.sarif --dry-run
```
