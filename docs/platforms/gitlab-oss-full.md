# GitLab OSS Full Pipeline (`oss-full`)

**Shared reference:** [oss-full-shared.md](oss-full-shared.md) (pins, gates, registry, ASPM, validation).

Profile for **GitLab CE / Self-hosted** without GitLab Ultimate Security templates.

```bash
./scripts/adopt.sh --profile oss-full --platform gitlab --target .
bash scripts/validate-gitlab-oss.sh
```

See also: [github-oss-full.md](github-oss-full.md) (GitHub Actions equivalent).

## Pipeline stages

```
validate → test → security → build → deploy → post-deploy
```

## Full job list (B–F)

| Job | Tool | Stage | Trigger |
|-----|------|-------|---------|
| `lint` / `unit-test` | Ruff / pytest | validate / test | MR, main |
| `conftest-admission` | Conftest | validate | path changes |
| `gitleaks-scan` | Gitleaks (docker) | security | MR, main |
| `forbidden-files` | shell + gate | security | MR, main |
| `semgrep-sast` | Semgrep | security | MR, main |
| `trivy-osa` | Trivy fs | security | MR, main |
| `checkov-iac` | Checkov | security | IaC paths |
| `dockerfile-lint` | Hadolint | security | Dockerfile paths |
| `linter-security` | Ruff | security | MR, main |
| `binary-fuzz` | AFL++ / Go / Jazzer | test | manual |
| `build-image` | Docker build+push | build | main |
| `sbom-generate` | Syft | build | main |
| `trivy-sca` | Trivy image | build | main |
| `deploy-preprod` | Helm | deploy | manual |
| `deploy-prod` | Helm | deploy | manual |
| `sign-image` | cosign | post-deploy | manual |
| `dast-zap` | ZAP baseline | post-deploy | manual |
| `api-fuzz-schemathesis` | Schemathesis | post-deploy | manual |
| `iast-preprod` | ZAP Full Scan | post-deploy | manual |
| `sec-func-tests` | pytest | test | MR, main |
| `sbom-upload` | Dependency-Track | post-deploy | manual |
| `nightly-sast-scheduled` | Semgrep | security | schedule |

Job files: `.gitlab/jobs/` (pins via `.gitlab/jobs/oss/versions.yml` from manifest).

## GitLab CE runner requirements

| Requirement | Jobs |
|-------------|------|
| **Docker executor + privileged** | `gitleaks-scan`, `binary-fuzz`, `build-image` (dind) |
| **Container Registry** | `build-image`, `trivy-sca`, `sign-image` |
| **KUBECONFIG** (file variable) | `deploy-preprod`, `deploy-prod` |

Register a runner with `privileged = true` for dind. See [GitLab Docker executor docs](https://docs.gitlab.com/runner/executors/docker.html#use-docker-in-docker).

## Required CI/CD variables

| Variable | Type | Purpose |
|----------|------|---------|
| `CI_REGISTRY_*` | builtin | Container Registry login (default backend `gitlab`) |
| `KUBECONFIG` | File, masked | kubectl/helm access to cluster |
| `PREPROD_URL` | Variable | DAST / IAST / Schemathesis target |
| `HELM_CHART_PATH` | Variable | Default `chart/` (copied on adopt) |
| `HELM_RELEASE` | Variable | Default `sample-app` |
| `NAMESPACE_PREPROD` / `NAMESPACE_PROD` | Variable | K8s namespaces |

Optional: `COSIGN_PRIVATE_KEY`, `DTRACK_*`, `DEFECTDOJO_*`, `REGISTRY_BACKEND` / Nexus — see [oss-full-shared.md](oss-full-shared.md).

## Kubernetes / Helm

On adopt, `templates/k8s/helm/sample-app/` → `chart/` if missing.

```bash
helm upgrade --install sample-app chart/ \
  --namespace preprod \
  --set image.repository=$CI_REGISTRY_IMAGE \
  --set image.tag=$CI_COMMIT_SHA
```

## MR vs main

| Trigger | Jobs |
|---------|------|
| MR | gitleaks, forbidden-files, semgrep, trivy-osa, checkov (if IaC), hadolint, linters, conftest; manual binary-fuzz |
| main | + build/push → sbom → trivy-sca; manual deploy / DAST / IAST / API fuzz / sign |

## Nightly SAST schedule

CI/CD → Schedules → New schedule → target branch `main`, cron e.g. `0 2 * * *`, job `nightly-sast-scheduled`.

## DefectDojo

GitLab uses `.aspm_export` after_script in each scanner job — see [runbooks/aspm-export.md](../runbooks/aspm-export.md).

## Validation

```bash
bash scripts/validate-gitlab-oss.sh
bash scripts/validate-yaml.sh
./scripts/adopt.sh --profile oss-full --platform gitlab --target /tmp/t --dry-run
```
