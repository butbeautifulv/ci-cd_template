# Nexus / External Docker Registry

Connect **Sonatype Nexus**, **Harbor**, **JFrog Artifactory**, or any Docker v2 registry to GitLab CI build/push/scan/sign jobs.

Default backend is **GitLab Container Registry** — no changes required for existing adopters.

## Backends

| `REGISTRY_BACKEND` | Use case |
|--------------------|----------|
| `gitlab` (default) | GitLab built-in Container Registry |
| `nexus` | Nexus Repository Manager docker-hosted |
| `harbor` | Harbor project registry |
| `artifactory` | JFrog Artifactory Docker repo |
| `generic` | Any Docker registry with user/password auth |

Manifest: [`config/artifact-registry.yaml`](../../config/artifact-registry.yaml)

## GitLab CI variables (Nexus example)

| Variable | Example | Masked |
|----------|---------|--------|
| `REGISTRY_BACKEND` | `nexus` | no |
| `REGISTRY_HOST` | `nexus.example.com:8082/repository/docker-hosted` | no |
| `REGISTRY_REPOSITORY` | `myorg/myapp` | no |
| `REGISTRY_USER` | `ci-bot` | no |
| `REGISTRY_PASSWORD` | `***` | **yes** |

Optional: set `REGISTRY` directly to the full image prefix instead of `REGISTRY_HOST` + `REGISTRY_REPOSITORY`:

```
nexus.example.com:8082/repository/docker-hosted/myorg/myapp
```

Image tag in pipeline: `${REGISTRY}:${CI_COMMIT_SHA}`

## Nexus setup

1. Create **docker-hosted** repository in Nexus (e.g. `docker-hosted`)
2. Create CI user with `nx-repository-view-docker-*-browse/read/write` roles
3. Enable Docker Bearer Token Realm if using `docker login`
4. Set CI variables above in GitLab → Settings → CI/CD → Variables

Push URL format:

```
nexus.example.com:8082/repository/docker-hosted/myorg/myapp:abc123def
```

## Harbor / Artifactory

Use `REGISTRY_BACKEND=harbor` or `artifactory` (same variable contract as `nexus`):

| Variable | Harbor example |
|----------|----------------|
| `REGISTRY_HOST` | `harbor.example.com/myproject` |
| `REGISTRY_REPOSITORY` | `myapp` |

## Jobs affected (oss-full)

| Job | Script |
|-----|--------|
| `build-image` | `registry-login.sh` → push |
| `trivy-sca` | `registry-auth-env.sh` → pull private image |
| `sign-image` | `registry-login.sh` → cosign |
| `deploy-*` | `${REGISTRY}` in Helm `--set image.repository` |

Snippet: [`templates/gitlab/jobs/registry/login.yml`](../../templates/gitlab/jobs/registry/login.yml)

## Kubernetes (C3)

Update Kyverno allowlist in [`templates/k8s/admission/kyverno-policies.yaml`](../../templates/k8s/admission/kyverno-policies.yaml):

```yaml
image: "nexus.example.com:8082/*|registry.internal.example.com/*"
```

See also [`templates/k8s/cluster/image-pull-policy.md`](../../templates/k8s/cluster/image-pull-policy.md).

## Local test

```bash
export REGISTRY_BACKEND=nexus
export REGISTRY_HOST=nexus.example.com:8082/repository/docker-hosted
export REGISTRY_REPOSITORY=myorg/myapp
export REGISTRY_USER=ci-bot
export REGISTRY_PASSWORD=secret
source scripts/registry-resolve-env.sh
echo "Image: ${REGISTRY}:test"
```

## Validation

```bash
bash scripts/validate-registry-config.sh
```
