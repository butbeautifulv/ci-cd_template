# DAF reference materials

Полные тексты DevSecOps Assessment Framework (Jet Infosystems) в репозитории.

| Файл | Описание |
|------|----------|
| [DAF_public_RU.md](DAF_public_RU.md) | Все практики T-/P- |
| [DAF_MLSO_public_RU.md](DAF_MLSO_public_RU.md) | MLSecOps практики |
| [LICENSE](LICENSE) | Beer-Ware License |

## Extracts (из xlsx)

Табличные данные: [../extracts/daf/](../extracts/daf/) — листы `Кирилламида`, `Практики`, `ГОСТ56939_mapping`, `miniRoadmap`, и др.

Регенерация (maintainer, опциональный локальный xlsx):

```bash
python scripts/extract_daf_xlsx.py --all-sheets
```

## Assets

- [../assets/daf/Heatmap.png](../assets/daf/Heatmap.png)
- [../assets/daf/The_Pyramid_of_Maturity.jpg](../assets/daf/The_Pyramid_of_Maturity.jpg)

## Синтез в template

- [../daf-kirillamida.md](../daf-kirillamida.md) — уровни зрелости
- [../../05-maturity-roadmap.md](../../05-maturity-roadmap.md) — roadmap
- Skill: `.agents/skills/devsecops-daf/`

Attribution: Jet Infosystems DevSecOps Team — см. [LICENSE](LICENSE).
