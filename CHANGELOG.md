# Changelog

## [1.0.0] — Template release

### Added

- Progressive CI profiles: `minimal`, `shift-left`, `supply-chain`, `full`
- `scripts/adopt.sh` — copy template into target repo
- `scripts/gate-check.py` — SARIF + policy enforcement
- `scripts/validate-policy.py`, `scripts/validate-yaml.sh`
- B6 security linters job (GitLab + GitHub)
- `examples/sample-app/` — scanner demo targets
- `templates/pre-commit/.pre-commit-config.yaml`
- `.github/workflows/validate-template.yml` — meta-CI
- Cursor: `AGENTS.md`, `.cursor/rules/`, execution plan
- AI optional: `docs/11-ai-security-appendix.md`, AI1 skill-scanner stub
- `docs/adoption-checklist.md`, `docs/quickstart.md`

### Hardened

- GitHub DAST chain wired in `ci.yml`
- Gate enforcement on B1–C2 jobs
- Kyverno: no-latest, require-labels, trusted-registry
- NetworkPolicy DNS egress
- Falco custom rules + SIEM field mapping
- pytest `@security` marker (D2)
- cosign / IAST manual defaults

### Documentation

- Platform branch protection CLI snippets (A1)
- Release gate GitHub environment example (D3)
- F2/F3 runbooks expanded

Scaffold phases P0–F3 documented in `docs/phases/` (original master plan).
