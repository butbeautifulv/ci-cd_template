# Sample app — security scanner demo

Intentionally weak artifacts for validating B–E phase scanners.

## Contents

| Path | Triggers |
|------|----------|
| `Dockerfile` | B5 dockerfile-lint, C2 **SCA** (image) |
| `requirements.txt` | B3 **OSA** (manifest deps) |
| `infra/main.tf` | B4 IaC (open security group) |
| `k8s/deployment.yaml` | B4 IaC, E1 admission (`privileged`, `:latest`) |
| `app/main.py` | B2 SAST (weak auth pattern) |

## Local scan

```bash
# From repo root
trivy fs examples/sample-app/
checkov -d examples/sample-app/infra/
hadolint examples/sample-app/Dockerfile
```

## Pipeline validation (v1.2+)

After adopting `shift-left` or **`oss-full`** profile, run scanners locally — expect findings:

| Scanner | Expected on sample-app |
|---------|------------------------|
| SAST (semgrep) | weak auth in `app/main.py` |
| OSA (trivy fs) | CVE in `requirements.txt` |
| SCA (trivy image) | CVE in built image layers |
| IaC (checkov) | open SG in `infra/main.tf` |
| Admission | `privileged`, `:latest` in `k8s/deployment.yaml` |

```bash
python3 ../../scripts/gate-check.py --control sbom --report /dev/null  # fails — missing SBOM
```

## oss-full adopt

```bash
./scripts/adopt.sh --profile oss-full --platform gitlab --target examples/sample-app --dry-run
# Includes chart/ for Helm deploy-preprod
```
