# AI2 — AI supply chain (BOM + pickle)

## Goal

AI artifact inventory and unsafe serialization detection (Cisco AI Defense + MLSO).

## DAF / Cisco

- `T-ADI-ART-ML-3-3` — ML-BOM (see ML2)
- [aibom](https://github.com/cisco-ai-defense/aibom), [pickle-fuzzer](https://github.com/cisco-ai-defense/pickle-fuzzer)

## Files

- `templates/gitlab/jobs/aibom.yml`
- `templates/gitlab/jobs/pickle-scan.yml`
- `config/security-gate-policy.yaml` → `aibom:`, `pickle_scan:`

## Gate

**warn** on main / MR (pickle on model paths).

## Acceptance

- [ ] `aibom.json` artifact on main
- [ ] Pickle scan on `models/**` changes
- [ ] Does not block standard app-only repos
