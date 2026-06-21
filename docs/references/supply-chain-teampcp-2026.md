# TeamPCP Supply Chain Incident (March 2026)

Brief reference for why OSS scanner versions are pinned in this template.

## Summary

**TeamPCP** was a coordinated supply-chain campaign targeting DevSecOps tooling:

1. **Trivy** — compromised release / installer path (**CVE-2026-33634**)
2. **LiteLLM** — malicious PyPI packages (versions **1.82.7**, **1.82.8**)
3. **Checkmarx Actions** — trojanized GitHub Actions in the wild

Attackers abused trust in `:latest` tags and rolling install scripts (`install.sh@main`) to exfiltrate CI secrets and redirect scans.

## Indicators (IOCs)

Reported malicious domains (verify against current vendor advisories):

- `scan.aquasecurtiy.org` (typosquat)
- `checkmarx.zone`
- `models.litellm.cloud`

## Recommendations (CSA / Kaspersky)

- Pin scanner images by **semver tag** or **digest** — never `:latest` / `:stable`
- Do not auto-update security scanners in production (e.g. Watchtower on `trivy:latest`)
- Install Trivy from **pinned GitHub release tarballs**, not `main` branch scripts
- Pin pip packages: `checkov==x.y.z`, `ruff==x.y.z`
- Rotate CI/CD secrets after any suspected compromise

## Template response (v1.4.2)

| Control | Implementation |
|---------|----------------|
| Version manifest | `config/oss-tool-versions.yaml` |
| CI variables | `templates/gitlab/jobs/oss/versions.yml` |
| Validation | `scripts/validate-oss-pins.sh` |
| Runbook | [oss-tool-pinning.md](../runbooks/oss-tool-pinning.md) |
| Policy | `tooling_pins` in `config/security-gate-policy.yaml` |

## External references

- [Kaspersky — TeamPCP supply chain](https://securelist.com/) *(search TeamPCP / Trivy 2026)*
- [CSA — software supply chain guidance](https://cloudsecurityalliance.org/)
- [LiteLLM security advisory](https://github.com/BerriAI/litellm/security/advisories) *(check vendor for GHSA IDs)*

> **Note:** CVE and package version numbers reflect the March 2026 campaign context documented in the internal pinning plan. Re-verify against current vendor advisories before changing pins.
