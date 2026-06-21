# Agents — DevSecOps CI/CD Template

## Execution plan

Track progress in [`.cursor/plans/devsecops-execution.plan.md`](.cursor/plans/devsecops-execution.plan.md).

Scaffold (P0–F3 docs + templates) is done. Current work: **hardening + adoption UX**.

## Rules

1. **One todo = one PR**, **≤5 files** changed
2. Mirror **GitLab** and **GitHub** job contracts (SARIF, exit codes)
3. **warn → block** in a separate micro-PR
4. WAF/RASP (F2) — runbooks only, not CI jobs
5. Do not commit `.external/`
6. Do not edit `.cursor/plans/devsecops_execution_plan_04e83d47.plan.md`

## Phase order

CF → G0 → V0 → H-CORE → H-PRE → H-P0…H-F3 → AI* (optional) → R

## Skills (start here)

| Skill | Use when |
|-------|----------|
| `devsecops-template` | Repo overview, routing |
| `devsecops-phase-impl` | Adding/hardening a sub-phase |
| `devsecops-external-sources` | DAF/JCSF xlsx lookup |
| `devsecops-daf` | Practice IDs, Kirillamida |
| `devsecops-fintech-sdlc` | SDLC swimlane, MR gates |

Full list: [README.md](README.md#agent-skills)

## Key paths

- Policy: `config/security-gate-policy.yaml`
- Gate script: `scripts/gate-check.py`
- Adopt: `scripts/adopt.sh --profile shift-left --platform gitlab --target /path`
- Profiles: `templates/profiles/`
- Example app: `examples/sample-app/`

## Cursor rules

- `.cursor/rules/phase-impl.mdc` — always apply
- `.cursor/rules/templates-ci.mdc` — when editing `templates/**`
