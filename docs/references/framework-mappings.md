# Маппинги DAF на внешние фреймворки

Источник: листы `DAF_public_RU.xlsx` → markdown extracts в [extracts/daf/](extracts/daf/).

| Лист Excel | Extract | Использование |
|------------|---------|---------------|
| `SAMM_mapping` | [extracts/daf/SAMM_mapping.md](extracts/daf/SAMM_mapping.md) | Gap analysis по SAMM |
| `DSOMM_mapping` | [extracts/daf/DSOMM_mapping.md](extracts/daf/DSOMM_mapping.md) | CI/CD maturity (DSOMM) |
| `BSIMM14_mapping` | [extracts/daf/BSIMM14_mapping.md](extracts/daf/BSIMM14_mapping.md) | Сравнение с BSIMM |
| `ГОСТ56939_mapping` | [extracts/daf/ГОСТ56939_mapping.md](extracts/daf/ГОСТ56939_mapping.md) | [08-compliance-gost-56939.md](../08-compliance-gost-56939.md) |
| `PT TableTop_mapping` | [extracts/daf/PT_TableTop_mapping.md](extracts/daf/PT_TableTop_mapping.md) | Табличные упражнения |
| `Практики` | [extracts/daf/Практики.md](extracts/daf/Практики.md) | Per-practice traceability |

## JCSF маппинги

Extracts в [extracts/jcsf/](extracts/jcsf/):

| Лист | Extract |
|------|---------|
| `CIS Docker` | [extracts/jcsf/CIS_Docker.md](extracts/jcsf/CIS_Docker.md) |
| `CIS Kubernetes` | [extracts/jcsf/CIS_Kubernetes.md](extracts/jcsf/CIS_Kubernetes.md) |
| `CIS Linux (Debian/RHEL)` | [extracts/jcsf/CIS_Linux_Debian.md](extracts/jcsf/CIS_Linux_Debian.md), [CIS_Linux_RHEL.md](extracts/jcsf/CIS_Linux_RHEL.md) |
| `Приказ 118` | [extracts/jcsf/Приказ_118.md](extracts/jcsf/Приказ_118.md) |

## FTE калькуляторы

| Лист | Extract |
|------|---------|
| `FTE AppSec` | [extracts/daf/FTE_AppSec.md](extracts/daf/FTE_AppSec.md) |
| `Расчет FTE DSO` | [extracts/daf/Расчет_FTE_DSO.md](extracts/daf/Расчет_FTE_DSO.md) |

## Результаты аудита

Лист `Результаты аудита` — [extracts/daf/Результаты_аудита.md](extracts/daf/Результаты_аудита.md); heatmap: [assets/daf/Heatmap.png](assets/daf/Heatmap.png).

## Lookup

```bash
rg "T-CODE-SST" docs/references/extracts/daf/ГОСТ56939_mapping.md
python scripts/extract_daf_xlsx.py --xlsx /path/to/DAF_public_RU.xlsx \
  --sheet "SAMM_mapping" --rows 10
```

Skill: `devsecops-reference-lookup`.
