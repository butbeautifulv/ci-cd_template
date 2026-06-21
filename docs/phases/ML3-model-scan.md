# ML3 — Model scan (preprod, manual)

## Goal

Adversarial / poisoning checks on model artifacts before prod — **manual job**, warn gate.

## DAF MLSO

- `T-MLDATA-DT-4-2`, `T-MLDATA-DT-4-3`
- Tools: ART, Alibi Detect (integrate in org pipeline)

## Files

- `templates/gitlab/jobs/ml-model-scan.yml`
- `config/security-gate-policy.yaml` → `ml_model:`

## Gate

**warn** — does not block standard CI.

## Acceptance

- [ ] Manual trigger on main
- [ ] Placeholder documents ART integration path
