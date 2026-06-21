---
name: devsecops-ai-security
description: >-
  Optional AI/ML security from Cisco AI Defense and DAF MLSecOps: skill scanning,
  MCP security, AI BOM, model provenance. Use for AI1/ML1 phases, not standard CI/CD.
---

# AI security (optional)

Sources: `docs/references/cisco-ai-defense.md`, `docs/11-ai-security-appendix.md`, `docs/10-mlsecops-appendix.md`

## When to use

- Repo contains `.cursor/skills/`, MCP configs, or ML models
- Not needed for standard web/app pipelines (P0–F3)

## Tools

| Tool | Scan target |
|------|-------------|
| skill-scanner | Agent SKILL.md files |
| mcp-scanner | MCP server definitions |
| aibom | AI dependencies |
| pickle-fuzzer | Python pickle in ML artifacts |

## CI jobs (optional)

- `templates/gitlab/jobs/skill-scanner.yml` — manual/warn
- Phase doc: `docs/phases/AI1-skill-scan.md`

## MLSecOps overlap

ML data gates: `T-MLDATA-DT-4-*` — see `devsecops-mlsecops` skill.

## PR scope

Same rules: ≤5 files, warn-only default for AI1.
