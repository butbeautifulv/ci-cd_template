# ML2 — ML-BOM artifact

## Goal

`ml-bom.json` alongside `sbom.cdx.json` on main (`T-ADI-ART-ML-3-3`).

## Files

- `templates/gitlab/jobs/ml-bom.yml`
- `config/security-gate-policy.yaml` → `ml_bom:`

## Gate

**warn** if missing on main.

## Acceptance

- [ ] Artifact published on main build
- [ ] Lists models/ and data/ paths
