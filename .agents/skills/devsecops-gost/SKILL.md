---
name: devsecops-gost
description: >-
  Maps ГОСТ Р 56939-2024 requirements to DAF practices and CI/CD pipeline
  controls. Use for compliance audits, release gates, or regulatory traceability.
---

# ГОСТ Р 56939-2024 compliance

Source: `DAF_public_RU.xlsx` sheet `ГОСТ56939_mapping` (561 rows).

Repo: `docs/08-compliance-gost-56939.md`, `docs/references/framework-mappings.md`.

## Pipeline-relevant sections

| GOST | Topic | DAF examples | Pipeline |
|------|-------|--------------|----------|
| 5.10 | Static analysis | T-CODE-SST-* | B2 sast |
| 5.11 | Dynamic analysis | T-PREPROD-DAST-* | D1 dast |
| 5.12 | Secure build system | T-DEV-BLD-*, T-DEV-CICD-* | A2, C1 |
| 5.13 | Build environment | T-DEV-BLD-1-* | runner hardening |
| 5.14 | Code access & integrity | T-DEV-SRC-* | A1 signed commits |
| 5.15 | Secrets | T-DEV-SM-*, T-CODE-SECDN-* | B1 |
| 5.16 | Composition analysis | T-CODE-SC-*, T-ADI-DEP-* | B3, C1 |
| 5.17 | Supply chain malware | T-CODE-SPC-*, SBOM verify | F3 |
| 5.18–5.19 | Security testing | T-PREPROD-SECTEST-* | D2 |
| 5.20 | Release to production | signing, gates | C4, D3 |
| 5.21 | Secure delivery | registry policy | C3 |

## Planning & education

| GOST | DAF |
|------|-----|
| 5.1 Planning | P-ROLE-RESP-2-4, P-ROLE-RESP-3-2 |
| 5.2 Training | P-EDU-AWR-* |
| 5.3 Security requirements | P-REQ-RD-*, P-REQ-CR-* |

## Lookup

```bash
python scripts/extract_daf_xlsx.py \
  --sheet "ГОСТ56939_mapping" --grep "5.10"
python scripts/extract_daf_xlsx.py \
  --sheet "ГОСТ56939_mapping" --grep "T-CODE-SC"
```

Columns: `ID_требования`, `Требование ГОСТ 56939-2024`, `Практика DAF`, `Является требованием?`, `Маппинг?`.

## Audit workflow

1. Fill maturity in DAF xlsx `Кирилламида` / `Результаты аудита`
2. For each GOST requirement, link pipeline artifact (SARIF, SBOM, checklist)
3. Cross-check SAMM/DSOMM via `SAMM_mapping`, `DSOMM_mapping` sheets

Fintech: DAF `Практики` sheet has **ПЗ ЦБ** column for regulated orgs.

More rows: [reference.md](reference.md)
