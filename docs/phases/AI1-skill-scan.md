# Skill / MCP security scan (optional)

## Goal

Scan agent skills and MCP configs on MR (Cisco AI Defense OSS).

## Files

- `templates/gitlab/jobs/skill-scanner.yml`
- `templates/gitlab/jobs/mcp-scan.yml`
- `scripts/ai-ml-scan.py` (fallback scanner)
- `config/security-gate-policy.yaml` → `skill_scan:`, `mcp_scan:`

## Gate

**warn only** — does not block standard app pipeline.

## Tools

- [skill-scanner](https://github.com/cisco-ai-defense/skill-scanner)
- [mcp-scanner](https://github.com/cisco-ai-defense/mcp-scanner)

## Acceptance

- [x] Jobs run on changes to `.cursor/skills/`, `.agents/skills/`, `mcp*.json`
- [x] `gate-check.py` without `|| true`
- [x] Profile `ai-ml` includes jobs

## Verification

```bash
python scripts/ai-ml-scan.py skill_scan --report /tmp/skill.sarif
python scripts/gate-check.py --control skill_scan --report /tmp/skill.sarif
```
