# PKI / certificates in Kubernetes (Deploy)

Secure SDLC **Deploy** — PKI practices from JCSF/CIS Kubernetes extract.

## Scope

Cluster TLS: API server, etcd, ingress, service mesh, workload certs.

## Checklist (JCSF / CIS)

| Practice | Action | JCSF / CIS ref |
|----------|--------|----------------|
| API server TLS | Verify `--tls-cert-file`, `--tls-private-key-file` | Orch-2-5 |
| etcd encryption | Enable encryption at rest for secrets | Orch-3-4 |
| Cert rotation | Document rotation cadence + automation | Orch-3-3 |
| Ingress TLS | Valid certs, no self-signed in prod | CIS K8s |
| mTLS internal | Service mesh or sidecar policy | MAN / gen |

## Rotation runbook

1. Issue new cert (internal CA / cert-manager)
2. Deploy to preprod, verify handshake
3. Rolling update prod with overlap window
4. Revoke old cert after TTL + 24h
5. Log change in ticket + SIEM (E4)

## IDS distinction

| Layer | Tool in template | Notes |
|-------|------------------|-------|
| Network IDS | Out of repo | Edge appliance / cloud IDS |
| Host/runtime | Falco (E3) | Syscall / K8s audit |
| App | RASP (F2) | In-process |

PKI failures are **infra runbooks**, not CI gates.

См. [extracts/jcsf/CIS_Kubernetes.md](../references/extracts/jcsf/CIS_Kubernetes.md), [F2-rasp-waf.md](../phases/F2-rasp-waf.md).
