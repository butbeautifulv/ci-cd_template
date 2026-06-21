# Changelog

## [1.3.0] — AI + MLSecOps (opt-in profile)

### Added

- Profile **`ai-ml`** (GitLab + GitHub) — shift-left + AI1 + ML1–ML2
- Jobs: `skill-scanner`, `mcp-scan`, `aibom`, `pickle-scan`, `ml-data-scan`, `ml-bom`, `ml-model-scan`
- `scripts/ai-ml-scan.py` — fallback scanner + BOM generators
- Phase docs: AI1–AI3, ML1–ML3
- `docs/runbooks/ai-runtime-guardrails.md`
- `examples/sample-ml-app/` — PII/skill/MCP/pickle demo targets
- Policy sections: `skill_scan`, `mcp_scan`, `ml_data`, `ml_bom`, `aibom`, `pickle_scan`, `ml_model`

### Gates

- **ML1 PII** — `ml_data` block on datasets (DAF `T-MLDATA-DT-4-1`)
- AI/MCP/aibom/pickle — warn (profile `ai-ml` only)

### Changed

- `adopt.sh` — profile `ai-ml`, copies `ai-ml-scan.py`
- `03-security-controls.md`, `sdlc-mapping.md` — AI/ML rows
- Skills `devsecops-ai-security`, `devsecops-mlsecops` updated

## [1.2.0] — Template hardening (GitLab-first gates)

### Added

- `docs/phases/B6-linter-security.md`, `P1-threat-model.md`, `F4-resilience.md`
- `templates/governance/threat-model-checklist.md`
- `templates/gitlab/jobs/forbidden-files.yml` (fintech MR gate, warn)
- Kyverno v2: hostPath, capabilities, readOnlyRootFS, seccomp (JCSF MAN)
- `docs/runbooks/pki-k8s.md`
- `gate-check.py` support for `sbom`, `dast`, `sec_func_tests`
- `adopt.sh` rewrites GitLab include paths; copies `nightly-sast.yml` for full/GitHub

### Hardened

- GitLab: SAST/SCA/IaC block C/H without `|| true` on gate-check
- GitLab: secrets/dockerfile/linters honest warn gates
- GitLab: SBOM, DAST, sec-func gate-check; conftest-admission fails on violation
- GitHub: mirror gate fixes; CodeQL gate; supply-chain profile + lint/test
- `sdlc-mapping.md` Coverage column; adoption-checklist v1.2

### Changed

- `docs/phases/E1-admission.md` — JCSF policy table
- `F2-rasp-waf.md` — PKI/IDS distinction

## [1.1.0] — References migration + Secure SDLC

### Added

- `docs/references/secure-sdlc-phases.md` — 8-stage Secure SDLC (Plan→Monitor)
- `docs/references/sdlc-mapping.md` — DAF ↔ template ↔ pipeline crosswalk
- `docs/references/daf/` — full DAF/MLSO markdown + LICENSE
- `docs/references/extracts/` — DAF/JCSF xlsx extracts, PDF text archives
- `docs/references/assets/` — DAF/JCSF images
- `.agents/skills/` — 12 canonical skills; `.cursor/skills/` stubs for discovery
- `devsecops-secure-sdlc`, `devsecops-reference-lookup` skills
- `scripts/extract_jcsf_xlsx.py`; extended `scripts/extract_daf_xlsx.py`

### Changed

- Core docs: SDLC three-model view, Secure SDLC column in controls matrix
- All runtime paths → `docs/references/` (no dependency on local vendor cache)
- `devsecops-external-sources` renamed → `devsecops-reference-lookup`
- Expanded `docs/references/cisco-ai-defense.md`

### Deprecated

- Local vendor cache directory (gitignored) — optional for maintainer re-extract only

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
