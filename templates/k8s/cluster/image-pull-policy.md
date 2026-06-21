# Trusted registry and image pull policy

## CI/CD

Set `REGISTRY` to internal registry or dependency proxy:

- GitLab: `CI_REGISTRY_IMAGE` or Dependency Proxy
- GitHub: `ghcr.io/org/repo` or internal mirror

Build workers must pull base images only from approved registries (`T-CODE-SC-2-2`).

## Kubernetes

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app
  namespace: production
imagePullSecrets:
  - name: internal-registry
```

## Image policy

- Use digest pin where possible: `image: registry.internal/app@sha256:...`
- `imagePullPolicy: Always` for mutable tags (discouraged)
- Block `latest` in admission policies (`templates/k8s/admission/`)

## Kyverno: deny external registries (C3)

Policy `trusted-registry-only` in `templates/k8s/admission/kyverno-policies.yaml`:

```yaml
# Only allow internal registry patterns
image: "registry.internal.example.com/*|ghcr.io/myorg/*"
```

Adjust patterns for your org before `kubectl apply`.

## Network

Egress from cluster nodes to public registries — deny by default; allow only proxy (`T-ADI-ART-2-1`).
