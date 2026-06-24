# Agents — Fabrica (DevSecOps CI/CD reference)

## Execution plan

Track progress in [`.cursor/plans/devsecops-execution.plan.md`](.cursor/plans/devsecops-execution.plan.md).

Scaffold (P0–F3 docs + templates) is done. v1.1: references migrated to `docs/references/`. **v1.3:** Cursor dev skills via cxado `make skills-link` → `shared/skills/` (`.agents/skills/` is generated; do not commit).

## Rules

1. **One todo = one PR**, **≤5 files** changed
2. Mirror **GitLab** and **GitHub** job contracts (SARIF, exit codes)
3. **warn → block** in a separate micro-PR
4. WAF/RASP (F2) — runbooks only, not CI jobs
5. Reference material lives in `docs/references/` — vendor xlsx/pdf not in git

## Phase order

CF → G0 → V0 → H-CORE → H-PRE → H-P0…H-F3 → AI* (optional) → R → MIG (references/skills)

## Skills (canonical: [cxado-skills](https://github.com/butbeautifulv/cxado-skills))

| Skill | cxado-skills path |
|-------|-------------------|
| devsecops-template | `devsecops/devsecops-template/` |
| devsecops-phase-impl | `devsecops/devsecops-phase-impl/` |
| devsecops-reference-lookup | `devsecops/devsecops-reference-lookup/` |
| devsecops-secure-sdlc | `devsecops/devsecops-secure-sdlc/` |
| devsecops-daf | `devsecops/devsecops-daf/` |
| devsecops-gost | `devsecops/devsecops-gost/` |
| devsecops-jcsf | `devsecops/devsecops-jcsf/` |
| devsecops-fintech-sdlc | `devsecops/devsecops-fintech-sdlc/` |
| devsecops-tooling | `devsecops/devsecops-tooling/` |
| devsecops-governance | `devsecops/devsecops-governance/` |
| devsecops-mlsecops | `devsecops/devsecops-mlsecops/` |
| devsecops-ai-security | `devsecops/devsecops-ai-security/` |

Cursor discovery: from [cxado](https://github.com/butbeautifulv/cxado) run `make bootstrap` (or `make skills-link`) for project-local `.agents/skills/` symlinks, or `make skills-install` for `~/.cursor/skills/`.

## Key paths

- Policy: `config/security-gate-policy.yaml`
- Gate script: `scripts/gate-check.py`
- Adopt: `scripts/adopt.sh --profile shift-left|ai-ml|oss-full --platform gitlab --target /path`
- Profiles: `templates/profiles/`
- References: `docs/references/` (DAF, extracts, Secure SDLC)
- AI/ML: `examples/sample-ml-app/`, profile `ai-ml`
- Example app: `examples/sample-app/`

## Cursor rules

- `.cursor/rules/phase-impl.mdc` — always apply
- `.cursor/rules/templates-ci.mdc` — when editing `templates/**`
