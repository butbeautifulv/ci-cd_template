# Маппинги DAF на внешние фреймворки

Источник: листы `DAF_public_RU.xlsx` (lookup в `.external`, не дублируется в repo).

| Лист Excel | Содержание | Использование |
|------------|------------|---------------|
| `SAMM_mapping` | OWASP SAMM ↔ DAF | Gap analysis по SAMM |
| `DSOMM_mapping` | OWASP DSOMM ↔ DAF | CI/CD maturity (DSOMM) |
| `BSIMM14_mapping` | BSIMM14 ↔ DAF | Сравнение с BSIMM |
| `ГОСТ56939_mapping` | ГОСТ Р 56939 ↔ DAF (561 строка) | [08-compliance-gost-56939.md](../08-compliance-gost-56939.md) |
| `PT TableTop_mapping` | AppSec Table Top ↔ DAF | Табличные упражнения |
| `Практики` | BSIMM, SAMM, DSOMM, ПЗ ЦБ, ГОСТ в колонках | Per-practice traceability в `DAF_public_RU.md` |

## JCSF маппинги

Листы в `JCSF v7_public.xlsx`:

| Лист | Содержание |
|------|------------|
| `CIS Docker` | CIS Docker Benchmark → ID практик JCSF |
| `CIS Kubernetes` | CIS K8s Benchmark → JCSF |
| `CIS Linux (Debian/RHEL)` | Hardening nodes |
| `Приказ 118` | ФСТЭК №118 → JCSF |

## FTE калькуляторы

| Лист | Назначение |
|------|------------|
| `FTE AppSec` | Оценка FTE AppSec |
| `Расчет FTE DSO` | Оценка FTE DevSecOps |

Используйте при планировании команды после аудита по DAF.

## Результаты аудита

Лист `Результаты аудита` — heatmap зрелости (см. `images/Heatmap.png` в DAF repo).

## Lookup

```bash
python .cursor/skills/devsecops-external-sources/scripts/extract_daf_xlsx.py \
  --sheet "SAMM_mapping" --rows 10
python .cursor/skills/devsecops-external-sources/scripts/extract_daf_xlsx.py \
  --sheet "ГОСТ56939_mapping" --grep "T-CODE-SST"
```
