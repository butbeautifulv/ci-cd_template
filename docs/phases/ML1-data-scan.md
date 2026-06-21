# ML1 — Dataset scan (PII block)

## Goal

Block merge/release when PII detected in training/RAG datasets (`T-MLDATA-DT-4-1`).

## DAF MLSO

- `T-MLDATA-DT-4-1` — block on PII
- `T-MLDATA-DT-4-2`, `4-3` — poisoning/adversarial (warn / future)

## Files

- `templates/gitlab/jobs/ml-data-scan.yml`
- `scripts/ai-ml-scan.py` (fallback without Presidio)
- `config/security-gate-policy.yaml` → `ml_data:`

## Gate

**block** on PII findings; upgrade to Presidio in production.

## Acceptance

- [ ] `examples/sample-ml-app/data/train.csv` fails gate
- [ ] Clean datasets pass
