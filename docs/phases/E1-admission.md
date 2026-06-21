# E1 — K8s admission policies

## DAF: `T-PROD-RUN-1-1`, `T-PROD-RUN-2-1` | JCSF: `Orch-2-13`, `Orch-3-1`

## Файлы

- `templates/k8s/admission/kyverno-policies.yaml`
- `templates/k8s/admission/policies/` (Conftest Rego)
- `templates/gitlab/jobs/conftest-admission.yml`
- `docs/phases/E1-admission.md`

## Kyverno policies (v2)

| Policy | JCSF | Purpose |
|--------|------|---------|
| disallow-privileged | MAN | No privileged pods |
| disallow-latest-tag | IMG | Image tag discipline |
| require-app-label | MAN | Metadata |
| require-resource-limits | MAN | CPU/mem limits |
| trusted-registry-only | IMG/C3 | Registry allowlist |
| disallow-host-path | MAN-1-2 | No hostPath |
| drop-all-capabilities | MAN-1-4 | Capabilities drop ALL |
| require-read-only-rootfs | MAN-2-3 | Immutable root FS |
| require-seccomp-profile | MAN-3-3 | seccomp RuntimeDefault |

## CI

GitLab: `conftest-admission` — **fails pipeline** on policy violation (no `allow_failure`).

GitHub: apply policies in cluster; Conftest CI test GitLab-only (document in platforms).

## Acceptance

- [ ] Kyverno policies applied on cluster
- [ ] Conftest job green on sample manifests
- [ ] JCSF MAN practices mapped in table above
