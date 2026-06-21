---
name: devsecops-daf
description: >-
  DAF DevSecOps Assessment Framework: Kirillamida maturity levels 0–7,
  technology and process subdomains, practice IDs, target-level algorithm.
  Use for control mapping, phase docs, or GOST/DAF traceability.
---

# DAF (DevSecOps Assessment Framework)

Sources: `.external/DevSecOps-Assessment-Framework-main/DAF_public_RU.md`, `DAF_public_RU.xlsx`.

Repo docs: `docs/references/daf-kirillamida.md`, `docs/05-maturity-roadmap.md`.

## Kirillamida levels

| № | Name | CI/CD meaning |
|---|------|---------------|
| 0 | Хаос | Ad-hoc |
| 1 | Минимальный | First tools |
| 2 | Базовый | **Default target start** |
| 3 | Повышенный | MR automation |
| 4 | Продвинутый | SBOM, DAST |
| 5 | Развитый | Signing, K8s |
| 6 | Экспертный | IAST, Red Team |
| 7 | Космический | Max maturity |

## Target level algorithm

1. Default → **2 Базовый**
2. Levels 0–2 at 80–100% → **3** or **4**
3. 0–2 at 80%+, any 3–5 below 80% → **5**
4. 0–5 at 80%+ → **6** or **7**

Lower-level practices have priority (`DAF README`).

## Practice ID format

`{T|P}-{DOMAIN}-{SUB}-{level}-{n}`

Examples: `T-CODE-SST-2-1`, `P-DEFECT-CNS-2-1`, `T-DEV-CICD-1-3`

## Lookup

```bash
rg "T-CODE-SST-2-1" .external/DevSecOps-Assessment-Framework-main/DAF_public_RU.md
python .cursor/skills/devsecops-external-sources/scripts/extract_daf_xlsx.py \
  --sheet "Практики" --grep "T-CODE-SST" --rows 5
```

## Subdomains

Full T-* and P-* tables: [reference.md](reference.md)

## Map to template

| DAF subdomain | Template |
|---------------|----------|
| T-CODE-SST | B2 sast |
| T-CODE-SC, T-ADI-DEP | B3 sca, C1 sbom |
| T-CODE-SECDN | B1 secrets |
| T-CODE-DOCKERFS | B5 dockerfile |
| T-PREPROD-MANSEC | B4 iac |
| T-CODE-IMG | C2 container-scan |
| T-PREPROD-DAST | D1 dast |
| T-PROD-RUN | E1 admission |
| P-DEFECT-CNS | ASTO / DefectDojo |

Framework crosswalks: `devsecops-gost`, `docs/references/framework-mappings.md`.
