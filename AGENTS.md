# Agents — DevSecOps CI/CD Template

## Execution plan

Track progress in [`.cursor/plans/devsecops-execution.plan.md`](.cursor/plans/devsecops-execution.plan.md).

Scaffold (P0–F3 docs + templates) is done. v1.1: references migrated to `docs/references/`, skills in `.agents/skills/`.

## Rules

1. **One todo = one PR**, **≤5 files** changed
2. Mirror **GitLab** and **GitHub** job contracts (SARIF, exit codes)
3. **warn → block** in a separate micro-PR
4. WAF/RASP (F2) — runbooks only, not CI jobs
5. Reference material lives in `docs/references/` — vendor xlsx/pdf not in git
6. Do not edit `.cursor/plans/devsecops_execution_plan_04e83d47.plan.md`

## Phase order

CF → G0 → V0 → H-CORE → H-PRE → H-P0…H-F3 → AI* (optional) → R → MIG (references/skills)

## Skills (`.agents/skills/`)

| Skill | Path |
|-------|------|
| devsecops-template | `.agents/skills/devsecops-template/` |
| devsecops-phase-impl | `.agents/skills/devsecops-phase-impl/` |
| devsecops-reference-lookup | `.agents/skills/devsecops-reference-lookup/` |
| devsecops-secure-sdlc | `.agents/skills/devsecops-secure-sdlc/` |
| devsecops-daf | `.agents/skills/devsecops-daf/` |
| devsecops-gost | `.agents/skills/devsecops-gost/` |
| devsecops-jcsf | `.agents/skills/devsecops-jcsf/` |
| devsecops-fintech-sdlc | `.agents/skills/devsecops-fintech-sdlc/` |
| devsecops-tooling | `.agents/skills/devsecops-tooling/` |
| devsecops-governance | `.agents/skills/devsecops-governance/` |
| devsecops-mlsecops | `.agents/skills/devsecops-mlsecops/` |
| devsecops-ai-security | `.agents/skills/devsecops-ai-security/` |

Cursor discovery: thin stubs in `.cursor/skills/` → canonical `.agents/skills/`.

## Key paths

- Policy: `config/security-gate-policy.yaml`
- Gate script: `scripts/gate-check.py`
- Adopt: `scripts/adopt.sh --profile shift-left --platform gitlab --target /path`
- Profiles: `templates/profiles/`
- References: `docs/references/` (DAF, extracts, Secure SDLC)
- Example app: `examples/sample-app/`

## Cursor rules

- `.cursor/rules/phase-impl.mdc` — always apply
- `.cursor/rules/templates-ci.mdc` — when editing `templates/**`
