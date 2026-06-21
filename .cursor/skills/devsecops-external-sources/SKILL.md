---
name: devsecops-external-sources
description: >-
  Reads and extracts content from .external reference materials (DAF xlsx/md,
  JCSF xlsx, fintech PDF, tools PDF). Use when auditing sources, verifying
  documentation completeness, or looking up data not in docs/.
---

# DevSecOps external sources

## Layout

```
.external/
├── DevSecOps-Assessment-Framework-main/
│   ├── DAF_public_RU.md          # full practice text
│   ├── DAF_MLSO_public_RU.md     # MLSecOps
│   └── DAF_public_RU.xlsx
├── Jet-Container-Security-Framework-main/
│   └── JCSF v7_public.xlsx
├── Типовой_процесс_безопасной_разработки_для_финтеха.pdf
└── Карта инструментов DevSecOps.pdf
```

Gitignored — read from disk, never commit.

## Extract script

```bash
python .cursor/skills/devsecops-external-sources/scripts/extract_daf_xlsx.py \
  --sheet "Кирилламида" --rows 5

python .cursor/skills/devsecops-external-sources/scripts/extract_daf_xlsx.py \
  --sheet "ГОСТ56939_mapping" --grep "T-CODE-SST"

python .cursor/skills/devsecops-external-sources/scripts/extract_daf_xlsx.py \
  --sheet "UNKNOWN" 2>&1   # prints available sheet names on error
```

Python 3 stdlib only. Run from repo root.

## PDF text

```bash
pdftotext ".external/Типовой_процесс_безопасной_разработки_для_финтеха.pdf" -
```

Prefer synthesized docs over raw PDF.

## xlsx sheet index

Full table: [references/xlsx-sheets.md](references/xlsx-sheets.md)

## Synthesized in repo

| Source | docs/ | skill |
|--------|-------|-------|
| DAF Kirillamida | `references/daf-kirillamida.md` | `devsecops-daf` |
| Framework mappings | `references/framework-mappings.md` | `devsecops-gost` |
| Fintech swimlane | `references/fintech-swimlane.md` | `devsecops-fintech-sdlc` |
| Tool catalog | `04-tooling-catalog.md` | `devsecops-tooling` |
| JCSF | `06-kubernetes-runtime.md` | `devsecops-jcsf` |
| MLSecOps | `10-mlsecops-appendix.md` | `devsecops-mlsecops` |

After extraction, update `docs/` — do not dump full xlsx into repo.
