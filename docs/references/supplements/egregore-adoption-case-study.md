# Egregore adoption case study (Fabrica shift-left + full CI)

Reference consumer: [egregore](https://github.com/butbeautifulv/egregore) — Python 3.13 / uv / FastAPI multi-agent SOC.

## Adopt command

```bash
cd projects/fabrica
./scripts/adopt.sh --profile shift-left --platform github --target ../egregore
# uv/Python 3.13 (auto-detected from uv.lock):
./scripts/adopt.sh --profile shift-left --platform github --target ../egregore --python-stack uv --policy adopt
```

`post-adopt.sh` runs automatically: copies adopt-policy, wires `sast-python`, sets policy refs.

## What egregore kept vs customized

| Area | Fabrica default (2026) | Egregore choice |
|------|------------------------|-----------------|
| Entry CI | `ci-profile.yml` + `security-shift-left.yml` | **Parallel:** `security-shift-left.yml` + full `ci.yml` + product gates |
| Policy day-1 | `security-gate-policy-adopt.yaml` (via `--policy adopt`) | Same — warn on noisy SAST/secrets/dockerfile |
| Linters B6 | uv auto-detect when `uv.lock` | **uv** + `uv run ruff` (Python 3.13) |
| SAST CodeQL | `sast-python` default (`sast_job` input) | **Python-only** via `jobs/sast-python.yml` |
| Reusable `with:` | literals / `github.*` only | No `env.REGISTRY` in `with:` |
| Deploy/DAST | `workflow_call` on deploy/dast workflows | Chain from `ci.yml` |
| Secrets | `secrets: inherit` on all reusable `uses:` | Same |

## Parallel security-shift-left

Product gates (`arch-gate.yml`, `adversarial-gate.yml`, `agent-policy-gate.yml`) stay independent. Security B1–B6 run via:

```yaml
# .github/workflows/security-shift-left.yml
jobs:
  security-gates:
    uses: ./.github/workflows/security-gates.yml
    secrets: inherit
    with:
      security_policy: config/security-gate-policy-adopt.yaml
      enable_real_linters: "true"
      sast_job: sast-python
```

Full `ci.yml` also calls `security-gates` after lint/unit — expect duplicate B-jobs on PR until you dedupe.

## Python / uv (zero manual patches)

With `uv.lock` in the target repo:

1. `adopt.sh --python-stack auto` (default) selects `sast-python` and uv-aware validate/linter jobs.
2. `base-validate.yml` and `linter-security.yml` auto-detect `uv.lock`.
3. CodeQL uses Python 3.13 in `jobs/sast-python.yml`.

For pip-only projects: `./scripts/adopt.sh ... --python-stack pip` switches to `sast_job: sast`.

## Policy ladder

1. **Day 1:** `--policy adopt` (default) — `security-gate-policy-adopt.yaml`, warn on noisy scanners.
2. **Triage:** review SARIF in GitHub Security tab + gate-check logs.
3. **Production:** `./scripts/adopt.sh ... --policy strict` or point `security_policy` at `config/security-gate-policy.yaml`.

## Common workflow parse failures (actionlint)

| Error | Fix |
|-------|-----|
| `context "env" is not allowed here` in `with:` | Use `github.repository` / literals, not `env.REGISTRY` |
| `workflow_call event trigger is not found` | Add `workflow_call:` to `deploy-preprod.yml`, `dast.yml` |
| `hashFiles` in job-level `if:` | Move to step `if:` or remove guard |
| Nested `SECURITY_POLICY` empty | Set `env` on `security-gates.yml` from `inputs`; jobs read `${{ env.SECURITY_POLICY }}` |

Caught locally: `make validate` → `scripts/validate-github-workflows.sh`.

## Branch protection (manual)

Required checks on `main` PRs (example):

- `security-gates / secrets` … `linters` (from shift-left)
- `Architecture Gate`, `Adversarial Gate` (product)
- `CI` orchestrator when supply-chain chain is active

## Next phases

| Phase | Fabrica profile | Notes |
|-------|-----------------|-------|
| AI/ML gates | `ai-ml` | `skill-scanner`, `mcp-scan` for `agents/skills/` |
| Supply chain | `supply-chain` | SBOM + container scan on `main` (stubs need registry) |
| ASPM | `gate-and-export` composite | Wire `DEFECTDOJO_*` vars or asoc-api NATS path |

See also: [fstec-adaptation-case-study.md](fstec-adaptation-case-study.md) (Node / `oss-full-node`).
