# GitLab OSS Full Pipeline (`oss-full`)

**Shared reference:** [oss-full-shared.md](oss-full-shared.md) (pins, gates, registry, ASPM, validation).

Profile for **GitLab CE / Self-hosted** without GitLab Ultimate Security templates.

```bash
./scripts/adopt.sh --profile oss-full --platform gitlab --target .
```

See also: [gitlab.md](gitlab.md) (profile `full` with GitLab Security templates).

## Pipeline stages

```
validate → test → security → build → deploy → post-deploy
```

## GitLab-specific jobs

| Job | Tool | Stage |
|-----|------|-------|
| `gitleaks-scan` | Gitleaks | security |
| `semgrep-sast` | Semgrep | security |
| `trivy-osa` | Trivy fs | security |
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

Job files: `.gitlab/jobs/oss/` — pins via `.gitlab/jobs/oss/versions.yml` (generated from manifest).

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
| MR | gitleaks, semgrep, trivy-osa, checkov (if IaC changed), hadolint, linters, conftest |
| main | + build/push → sbom → trivy-sca; manual deploy/DAST/sign |

## DefectDojo

GitLab uses `.aspm_export` after_script in each scanner job — see [runbooks/aspm-export.md](../runbooks/aspm-export.md).
