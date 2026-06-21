# Namespace allowlist — customize per microservice (T-PROD-NETWORK-3-1)

| Namespace | Allowed ingress from | Allowed egress to |
|-----------|---------------------|-------------------|
| production | ingress-nginx, monitoring | database-ns, internal-apis |
| preprod | ingress-nginx, ci-runners | database-preprod |
| kube-system | — | — |

Apply per-namespace NetworkPolicy manifests derived from `default-deny.yml` template.
