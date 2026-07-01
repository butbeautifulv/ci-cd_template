# K8s workload baseline

Checklist for workloads deployed via Fabrica Helm/K8s templates (kubernetes-specialist patterns).

## MUST

- Set `resources.requests` and `resources.limits` on every container
- Define `livenessProbe` and `readinessProbe`
- Use a dedicated `ServiceAccount` (not `default`)
- Run as non-root (`runAsNonRoot: true`, explicit UID)
- Pin image tags — never `latest` in production
- Label pods consistently (`app.kubernetes.io/name`, version)
- Apply `NetworkPolicy` for namespace segmentation ([default-deny.yml](../../templates/k8s/network/default-deny.yml))

## MUST NOT

- Run privileged containers without documented exception
- Mount `hostPath` in app workloads
- Store secrets in ConfigMaps or plain env vars
- Skip health checks
- Use `imagePullPolicy: Always` with floating tags

## Fabrica templates

| Artifact | Path |
|----------|------|
| Reference Helm chart | [templates/k8s/helm/sample-app/](../../templates/k8s/helm/sample-app/) |
| Kyverno admission | [templates/k8s/admission/kyverno-policies.yaml](../../templates/k8s/admission/kyverno-policies.yaml) |
| Intentionally weak demo | [examples/sample-app/k8s/deployment.yaml](../../examples/sample-app/k8s/deployment.yaml) |

Validate chart: `make validate-helm`

## Related

- Phase [E1-admission.md](../phases/E1-admission.md)
- Docker images: [docker-production-baseline.md](docker-production-baseline.md)
