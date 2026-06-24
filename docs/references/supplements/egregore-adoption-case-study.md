# Egregore adoption case study (Fabrica shift-left + full CI)

Reference consumer: [egregore](https://github.com/butbeautifulv/egregore) — Python 3.13 / uv / FastAPI multi-agent SOC.

## Adopt command

```bash
cd projects/fabrica
./scripts/adopt.sh --profile shift-left --platform github --target ../egregore
```

## What egregore kept vs customized

| Area | Fabrica default | Egregore choice |
|------|-----------------|-----------------|
| Entry CI | `ci-profile.yml` only | **Parallel:** `security-shift-left.yml` + full `ci.yml` + product gates |
| Policy day-1 | `security-gate-policy.yaml` | `security-gate-policy-adopt.yaml` (`sast.mode: warn`) |
| Linters B6 | pip + Ruff | **uv** + `uv run ruff` (Python 3.13) |
| SAST CodeQL | JS + Python | **Python-only** (`jobs/sast.yml` or use `jobs/sast-python.yml`) |
| Reusable `with:` | `image: ${{ env.REGISTRY }}:...` | **Invalid** — use `ghcr.io/${{ github.repository }}:${{ github.sha }}` |
| Deploy/DAST | push/dispatch only | Add `workflow_call` trigger for `ci.yml` chain |
| Secrets | implicit | `secrets: inherit` on all `uses:` reusable jobs |

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
```

Full `ci.yml` also calls `security-gates` after lint/unit — expect duplicate B-jobs on PR until you dedupe.

## Python / uv post-adopt patch

If the target uses `uv.lock`:

1. Patch `jobs/linter-security.yml` — use template `linter-security.yml` (auto-detects `uv.lock`).
2. Optionally swap `jobs/sast.yml` → `jobs/sast-python.yml` in `security-gates.yml`.
3. Set `setup-python` / CodeQL to **3.13** to match `pyproject.toml`.

No `adopt.sh --python-stack` flag yet — apply patches in a follow-up PR after adopt.

## Policy ladder

1. **Day 1:** `security-gate-policy-adopt.yaml` — warn on noisy SAST/secrets/dockerfile.
2. **Triage:** review SARIF in GitHub Security tab + gate-check logs.
3. **Production:** point `security_policy` input at `security-gate-policy.yaml` (`sast.mode: block`).

## Common workflow parse failures (actionlint)

| Error | Fix |
|-------|-----|
| `context "env" is not allowed here` in `with:` | Use `github.repository` / literals, not `env.REGISTRY` |
| `workflow_call event trigger is not found` | Add `workflow_call:` to `deploy-preprod.yml`, `dast.yml` |
| `hashFiles` in job-level `if:` | Move to step `if:` or remove guard |
| Nested `SECURITY_POLICY` empty | Set `env` on `security-gates.yml` from `inputs`; jobs read `${{ env.SECURITY_POLICY }}` |

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
