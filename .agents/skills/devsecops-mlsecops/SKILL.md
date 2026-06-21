---
name: devsecops-mlsecops
description: >-
  MLSecOps practices from DAF_MLSO for ML/AI systems: data poisoning, PII in
  datasets, ML-BOM, adversarial attacks. Use when extending pipeline for ML
  projects, not for standard app CI/CD.
---

# MLSecOps (optional)

Sources: `DAF_MLSO_public_RU.md`, xlsx sheet `Практики+MLSecOps`

Repo: `docs/10-mlsecops-appendix.md`

**Not in base P0–F3 template.** Enable for ML/AI repos only.

## Domains

| Domain | Examples |
|--------|----------|
| Data protection | T-MLDATA-DT — training/RAG data |
| Model protection | adversarial, poisoning |
| AI runtime | inference guardrails |
| Artifacts | T-ADI-ART-ML-*, MLflow cards |

## CI/CD gate practices

| ID | Gate |
|----|------|
| T-MLDATA-DT-4-1 | Block build on PII in data |
| T-MLDATA-DT-4-2 | Block on poisoned data |
| T-MLDATA-DT-4-3 | Block on adversarial data attacks |
| T-ADI-ART-ML-3-3 | ML-BOM artifact required |

## Tools (DAF MLSO)

- Presidio, ARX — PII detection
- Alibi Detect, ART — poisoning / adversarial
- DVC, MLflow — versioning

## Suggested jobs (after B-phase)

1. `ml-data-scan` — PII/poisoning on datasets in MR
2. `ml-model-scan` — adversarial robustness in preprod
3. Artifact `ml-bom.json` alongside `sbom.cdx.json`

Create `docs/phases/ML1-data-scan.md` when adopting.

Details: [reference.md](reference.md)
