# Changelog

## [1.5.1] — Fail-closed gate check + dead/deprecated scanner actions

Fixed against real-world CI experience from egregore/veil, which surfaced a class of
bug this repo's templates hadn't been run against real GitHub Actions runners for.

### Fixed

- **`scripts/gate-check.py`** — a missing scan report (crashed/misconfigured/never-run
  tool) was treated identically to a clean scan (0 findings, gate passes). Now fails
  closed in `mode: block` and warns loudly (but still passes) in `mode: warn`.
- **`templates/github/actions/gate-and-export/action.yml`** — the shared "Ensure
  report exists" step fabricated an empty-but-valid SARIF whenever the real report
  was missing, defeating the gate for every job that uses it (checkov, gitleaks,
  semgrep, trivy, hadolint, ruff — 9 call sites). Now only normalizes a report the
  scanner actually produced; a genuinely missing report reaches gate-check.py as such.
- Same fabricated-empty-SARIF fallback removed from ~15 more job templates
  (GitHub `jobs/iac-scan.yml`, `jobs/oss/checkov-iac.yml`, `security-gates-oss.yml`;
  GitLab `jobs/oss/{checkov-iac,trivy-osa,gitleaks,semgrep-sast,trivy-sca}.yml`) —
  self-contained checks that always produce a real result (`forbidden-files.yml`,
  `sec-func-tests.yml`) were left as-is.
- **`gitleaks/gitleaks-action@v2`** (`jobs/secret-scan.yml`) never left a report file
  in the workspace — it only uploads a SARIF as a GitHub artifact, and only when it
  finds a leak — so the gate check always evaluated a fabricated empty report. It's
  also a commercial product requiring `GITLEAKS_LICENSE` for org-owned repos, and v2
  (Node 20) is past GitHub's default-runtime deprecation cutover. Replaced with the
  same pinned-container Gitleaks CLI approach already used correctly in
  `jobs/oss/gitleaks.yml`.
- **`returntocorp/semgrep-action@v1`** — both it and its `semgrep/semgrep-action`
  parent are archived/deprecated on GitHub. Replaced with direct
  `semgrep scan --config p/ci --sarif` inside a pinned `semgrep/semgrep` container
  across `jobs/sast.yml`, `jobs/sast-python.yml`, `nightly-sast.yml`. All
  `returntocorp/semgrep` Docker image references standardized to `semgrep/semgrep`.
- **`jobs/sast.yml`** analyzed `javascript, python` in one CodeQL job but hardcoded
  the upload category to `/language:javascript` — Python SAST findings were
  structurally never gated. Switched to a `matrix: language: [javascript, python]`
  (GitHub's own recommended pattern for multi-language CodeQL), each language now
  gets its own category and its own gate check.
- **`aquasecurity/trivy-action@0.28.0`** (`jobs/osa.yml`, `jobs/sca-image.yml`) —
  not a real tag (trivy-action tags are `v`-prefixed); this action reference would
  fail to resolve at runtime. Pinned to the real, current `v0.36.0`.
- `jobs/ml-model-scan.yml` (GitHub + GitLab) is an unimplemented placeholder (no
  model-format/adversarial scanner is wired up) — it now says so explicitly instead
  of silently presenting a fabricated clean SARIF as if a scan ran.
- `github/codeql-action/upload-sarif` pins standardized to `@v4` (were split v3/v4).

## [1.5.0] — GitHub OSS Full Pipeline

### Added

- Profile **`oss-full`** for GitHub Actions — [`templates/profiles/oss-full.github.yml`](templates/profiles/oss-full.github.yml)
- **`templates/github/workflows/security-gates-oss.yml`** — 100% OSS scanners (no CodeQL)
- OSS job workflows: `templates/github/workflows/jobs/oss/` (Gitleaks, Semgrep, Trivy OSA, Checkov, Hadolint, Ruff)
- **`templates/github/workflows/oss/`** — build-push (GHCR), sca-image (Trivy tarball)
- **`jobs/sbom-oss.yml`**, **`jobs/sign-oss.yml`**, **`dast-oss.yml`**, **`nightly-sast-oss.yml`**
- **`config/github-oss-env.yml`** — pinned env reference
- **`scripts/validate-github-oss.sh`**
- [docs/platforms/github-oss-full.md](docs/platforms/github-oss-full.md)
- CI: [`.github/workflows/oss-full-sample-app.yml`](.github/workflows/oss-full-sample-app.yml)

### Changed

- `adopt.sh` — `oss-full` + `github` activates `ci.yml`, copies OSS workflows
- `jobs/sbom.yml` — Syft `v1.20.0` pin for non-oss profiles
- `oss-tool-versions.yaml` — `github_actions` section
- Docs: quickstart, README, templates/README, devsecops-tooling skill

## [1.4.3] — External Docker registry (Nexus / Harbor)

### Added

- **`config/artifact-registry.yaml`** — registry backend manifest (gitlab, nexus, harbor, artifactory, generic)
- **`templates/gitlab/jobs/registry/`** — `variables.yml` + `.registry_login` / `.registry_auth_env` snippets
- **`scripts/registry-login.sh`**, **`registry-auth-env.sh`**, **`registry-resolve-env.sh`**
- **`scripts/validate-registry-config.sh`**
- [docs/runbooks/nexus-docker-registry.md](docs/runbooks/nexus-docker-registry.md)
- Policy section `artifact_registry` in `config/security-gate-policy.yaml`

### Changed

- Profile **`oss-full`**: build/push/scan/sign use vendor-neutral registry login
- Jobs: `oss/build-push.yml`, `oss/trivy-sca.yml`, `sign.yml`, `_base.yml` `build-image`
- All GitLab profiles include `registry/` snippets for `_base` compatibility
- `adopt.sh` — copies registry config + scripts
- `validate-yaml.sh` — invokes `validate-registry-config.sh`
- [docs/platforms/gitlab-oss-full.md](docs/platforms/gitlab-oss-full.md), [docs/phases/C3-registry.md](docs/phases/C3-registry.md)

## [1.4.2] — OSS tool version pinning (post TeamPCP)

### Added

- **`config/oss-tool-versions.yaml`** — single manifest for OSS scanner/tool versions
- **`templates/gitlab/jobs/oss/versions.yml`** — GitLab `OSS_*` variables mirroring manifest
- **`scripts/validate-oss-pins.sh`** — fails on `:latest`, `:stable`, Trivy `main`, unpinned pip
- [docs/runbooks/oss-tool-pinning.md](docs/runbooks/oss-tool-pinning.md)
- [docs/references/supply-chain-teampcp-2026.md](docs/references/supply-chain-teampcp-2026.md)
- Policy section `tooling_pins` in `config/security-gate-policy.yaml`

### Changed

- Profile **`oss-full`**: all scanner jobs use pinned images/versions (Semgrep, Trivy tarball, Checkov, Syft, Hadolint, Conftest, ZAP, Helm, Docker, Python, Ruff, Gitleaks)
- Trivy install: GitHub release tarball instead of `install.sh@main`
- Shared jobs: `sbom.yml`, `dockerfile-lint.yml`, `conftest-admission.yml`, `dast.yml`, `_base.yml`
- `adopt.sh` — copies `oss-tool-versions.yaml`; validation includes `validate-oss-pins.sh`
- `validate-yaml.sh` — invokes OSS pin validator
- [docs/platforms/gitlab-oss-full.md](docs/platforms/gitlab-oss-full.md) — version pinning section
- [docs/adoption-checklist.md](docs/adoption-checklist.md) — OSS pins checklist

## [1.4.1] — DefectDojo ASPM export

### Added

- **`scripts/aspm-export.py`** — platform-agnostic findings export (noop / defectdojo)
- **`config/aspm-export.yaml`** — control → DefectDojo `scan_type` mapping
- **`.gitlab/jobs/aspm/export-after-script.yml`** — per-scan upload snippet
- Profile **`oss-full`**: all scanner jobs export to DefectDojo in `after_script`
- [docs/runbooks/aspm-export.md](docs/runbooks/aspm-export.md)
- [docs/references/defectdojo-api.md](docs/references/defectdojo-api.md)
- Policy section `aspm_export`

### Changed

- `adopt.sh` — copies `aspm-export.yaml` + `aspm-export.py`
- `devsecops-tooling` skill — ASPM export paths

## [1.4.0] — GitLab OSS Full Pipeline

### Added

- **OSA / SCA split** (DAF 4.3.2 / 4.3.3): `osa:` manifest scan on MR, `sca:` container image post-SBOM
- Jobs: `osa.yml`, `oss/trivy-osa.yml`, `oss/trivy-sca.yml` (image); `sca.yml` legacy alias
- Phase docs: [B3-osa.md](docs/phases/B3-osa.md), updated [C2-image-scan.md](docs/phases/C2-image-scan.md)
- Profile **`oss-full`** — 100% open-source scanners (no GitLab Security templates)
- OSS jobs: `templates/gitlab/jobs/oss/` — Gitleaks, Semgrep, Trivy (fs+image), Checkov
- `oss/build-push.yml` — docker login, build, push to GitLab Registry
- `oss/helm-deploy.yml` — Helm deploy preprod + prod (manual)
- `oss/sbom-upload.yml` — Dependency-Track upload (manual)
- Helm chart: `templates/k8s/helm/sample-app/` + `examples/sample-app/chart/`
- [docs/platforms/gitlab-oss-full.md](docs/platforms/gitlab-oss-full.md)

### Changed

- `sign.yml` — real cosign sign (keyless or `COSIGN_PRIVATE_KEY`); optional needs for `trivy-container` / `container_scanning`
- `adopt.sh` — profile `oss-full`, copies `chart/` on adopt
- `templates/README.md`, `docs/quickstart.md` — oss-full ladder step

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
