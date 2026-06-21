# Extracts — DAF / JCSF / PDF archives

Markdown tables generated from vendor xlsx (not committed). Regenerate when upstream DAF/JCSF releases change.

## Contents

| Directory | Source | Sheets |
|-----------|--------|--------|
| `daf/` | DAF_public_RU.xlsx | Кирилламида, Практики, ГОСТ56939_mapping, miniRoadmap, … |
| `jcsf/` | JCSF v7_public.xlsx | Практики, CIS Kubernetes, CIS Docker, … |
| `fintech-pdf.txt` | Fintech process PDF | pdftotext archive |
| `tools-map-pdf.txt` | DevSecOps tools map PDF | pdftotext archive |

## Regenerate (maintainer)

Obtain xlsx from [Jet DAF](https://github.com/Jet-Security-Team/DevSecOps-Assessment-Framework) / JCSF repo locally, then:

```bash
python scripts/extract_daf_xlsx.py --xlsx /path/to/DAF_public_RU.xlsx --all-sheets
python scripts/extract_jcsf_xlsx.py --xlsx "/path/to/JCSF v7_public.xlsx" --all-sheets
```

Optional PDF text:

```bash
pdftotext /path/to/fintech.pdf docs/references/extracts/fintech-pdf.txt
pdftotext "/path/to/tools map.pdf" docs/references/extracts/tools-map-pdf.txt
```

Skill: `.agents/skills/devsecops-reference-lookup/`
