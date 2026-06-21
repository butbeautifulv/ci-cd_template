# AI1 — Skill / MCP security scan (optional)

## Goal

Scan agent skills and MCP configs on MR (Cisco AI Defense OSS).

## Files

- `templates/gitlab/jobs/skill-scanner.yml`
- `templates/github/workflows/jobs/skill-scanner.yml`
- `docs/phases/AI1-skill-scan.md`

## Gate

**warn only** — manual trigger default.

## Tools

- [skill-scanner](https://github.com/cisco-ai-defense/skill-scanner)
- [mcp-scanner](https://github.com/cisco-ai-defense/mcp-scanner)

## DAF / Cisco

Integrated AI Security Framework; see `docs/11-ai-security-appendix.md`.

## Критерии приёмки

- [x] Job runs on changes to `.cursor/skills/**`
- [x] Does not block standard app pipeline
- [x] Documented in AI appendix

## Verification

```bash
# When skill-scanner CLI installed:
skill-scanner scan .cursor/skills/
```
