# Sample app — security scanner demo

Intentionally weak artifacts for validating B–E phase scanners.

## Contents

| Path | Triggers |
|------|----------|
| `Dockerfile` | B5 dockerfile-lint, C2 **SCA** (image) |
| `requirements.txt` | B3 **OSA** (manifest deps) |
| `infra/main.tf` | B4 IaC (open security group) |
| `infra/secure/main.tf` | B4 contrast — least-privilege SG for triage |
| `infra/tests/*.tftest.hcl` | Terraform test (plan mode) |
| `k8s/deployment.yaml` | B4 IaC, E1 admission (`privileged`, `:latest`) |
| `app/main.py` | B2 SAST (weak auth pattern) |

## Docker: weak vs hardened

| Aspect | `Dockerfile` (scanner demo) | `Dockerfile.hardened` (reference) |
|--------|----------------------------|-------------------------------------|
| Stages | single | multi-stage (`deps` + `runtime`) |
| User | `USER 10001` (no group) | dedicated `app` user/group |
| Health | none | `HEALTHCHECK` on `/` |
| Base | `python:3.11-slim` | `python:3.13-slim` |
| Context | full tree | `.dockerignore` trims build context |

Use `Dockerfile` in CI gates (expect hadolint/SCA findings). Copy patterns from `Dockerfile.hardened` for production.

See [docker-production-baseline.md](../../docs/runbooks/docker-production-baseline.md).

## Local scan

```bash
# From repo root
trivy fs examples/sample-app/
checkov -d examples/sample-app/infra/
hadolint examples/sample-app/Dockerfile
# Terraform unit test (requires terraform >= 1.6)
cd examples/sample-app/infra && terraform init && terraform test -filter=unit_test -verbose
```

## Pipeline validation (v1.2+)

After adopting `shift-left` or **`oss-full`** profile, run scanners locally — expect findings:

| Scanner | Expected on sample-app |
|---------|------------------------|
| SAST (semgrep) | weak auth in `app/main.py` |
| OSA (trivy fs) | CVE in `requirements.txt` |
| SCA (trivy image) | CVE in built image layers |
| IaC (checkov) | open SG in `infra/main.tf` |
| IaC contrast | restricted SG in `infra/secure/main.tf` |
| Admission | `privileged`, `:latest` in `k8s/deployment.yaml` |

```bash
python3 ../../scripts/gate-check.py --control sbom --report /dev/null  # fails — missing SBOM
```

## oss-full adopt

```bash
./scripts/adopt.sh --profile oss-full --platform gitlab --target examples/sample-app --dry-run
./scripts/adopt.sh --profile oss-full --platform github --target examples/sample-app --dry-run
# GitLab: includes chart/ for Helm deploy-preprod
# GitHub: activates ci.yml with GHCR build/push
```
