# GitLab enterprise deploy — multi-contour Helm

Mapping between **common-templates** variables and **ci-cd_template** Helm jobs for Kaniko + Helm consumers.

## When to use

- Multiple K8s contours (INT, UAT, PROD) from one pipeline
- Group-level kubeconfig file variables (`KUBE_INT_CONFIG`, `KUBE_PROD_CONFIG`)
- Namespace suffix drives contour (`team-app-int`, `team-app-prod`)

Default `oss-full` uses fixed `preprod`/`prod` namespaces in [`helm-deploy.yml`](../../../templates/gitlab/jobs/oss/helm-deploy.yml).  
Enterprise variant: [`helm-deploy-contour.yml`](../../../templates/gitlab/jobs/oss/helm-deploy-contour.yml) + profile [`oss-full-enterprise.gitlab-ci.yml`](../../../templates/profiles/oss-full-enterprise.gitlab-ci.yml).

## Variable mapping

| common-templates | ci-cd_template contour job |
|------------------|----------------------------|
| `HELM_NAMESPACE` | `HELM_NAMESPACE` (suffix `-int`, `-prod`, …) |
| `KUBE_INT_CONFIG` | `KUBE_${HELM_DEST}_CONFIG` |
| `HELM_ENV_GIS_INT` | `HELM_ENV_${PREFIX}_${HELM_DEST}` |
| `HELM_APP_NAME` | `HELM_RELEASE` / `HELM_APP_NAME` |
| `DOCKER_REGISTRY` | `REGISTRY` / `CI_REGISTRY_IMAGE` |
| `DAST_WEBSITE` | `PREPROD_URL` or `DAST_WEBSITE` |
| `DEFECTDOJO_URL` + `DEFECTDOJO_TOKEN` | same + upload wave jobs |

## Contour resolution

Namespace suffix → `HELM_DEST`:

| Suffix | Contour | Typical kubeconfig var |
|--------|---------|------------------------|
| `*-prod` | PROD | `KUBE_PROD_CONFIG` |
| `*-int` | INT | `KUBE_INT_CONFIG` |
| `*-uat` | UAT | `KUBE_UAT_CONFIG` |
| `*-test`, `*-dev` | TEST | `KUBE_TEST_CONFIG` |

## Deploy safety

- Deploy job `needs: trivy-sca optional: true` — SCA skip does not block Helm
- Security scans `allow_failure: true` in enterprise warn-only mode
- Use [`security-gate-policy-adopt.yaml`](../../../config/security-gate-policy-adopt.yaml) for day-1 non-blocking gates

## Adoption

```bash
./scripts/adopt.sh --profile oss-full-enterprise --platform gitlab --target .
# or manual:
cp templates/profiles/oss-full-enterprise.gitlab-ci.yml .gitlab-ci.yml
cp -r templates/gitlab/jobs .gitlab/jobs
```

## Bridge: common-templates roles ↔ template jobs

| common-templates role | ci-cd_template job |
|----------------------|------------------|
| `gitlab.secret.test.yaml` | `oss/gitleaks.yml` |
| `gitlab.sast.test.yaml` | GitLab Ultimate / `oss/semgrep-sast.yml` |
| `trivy.test.yaml` (fs) | `oss/trivy-osa.yml` |
| `trivy.image.yaml` | `oss/trivy-sca.yml` |
| `checkov.test.yaml` | `oss/checkov-iac.yml` |
| `hadolint.test.yaml` | `dockerfile-lint.yml` |
| `syft.sbom.yaml` | `sbom.yml` |
| `defectdojo.upload.yaml` | `aspm/upload-*.yml` |
| `helm.template.yaml` | `oss/helm-deploy-contour.yml` |
| `gitlab.dast.test.yaml` | `dast.yml` |

See [common-templates-adaptation-case-study.md](common-templates-adaptation-case-study.md).
