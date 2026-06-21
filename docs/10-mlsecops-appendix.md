# MLSecOps — опциональное приложение

Источник: `DAF_MLSO_public_RU.md`, лист `Практики+MLSecOps` в `DAF_public_RU.xlsx`.

Не входит в базовый CI/CD шаблон (фазы P0–F3). Подключайте при разработке ML/ИИ систем.

## Дополнительные домены

| Домен | Поддомены (примеры) |
|-------|---------------------|
| Анализ и защита данных | `T-MLDATA-DT` — обучающие/валидационные данные, RAG |
| Анализ и защита ML-моделей | adversarial, poisoning |
| Runtime систем ИИ | инференс, guardrails |
| Артефакты | ML-BOM (`T-ADI-ART-ML-*`), карточки моделей (MLflow) |

## Практики с CI/CD gate

| ID | Суть |
|----|------|
| T-MLDATA-DT-4-1 | Блок сборки при ПДн в данных |
| T-MLDATA-DT-4-2 | Блок при отравленных данных |
| T-MLDATA-DT-4-3 | Блок при состязательных атаках на данные |
| T-ADI-ART-ML-3-3 | ML-BOM для артефактов ИИ |

## Инструменты (из DAF MLSO)

- Presidio, ARX — PII в данных
- Alibi Detect, ART — отравление / adversarial
- DVC, MLflow — версионирование данных и моделей

## Интеграция в pipeline

Добавьте jobs после B-фазы:

1. `ml-data-scan` — PII / poisoning на датасетах в MR
2. `ml-model-scan` — adversarial robustness (preprod)
3. Артефакт `ml-bom.json` рядом с `sbom.cdx.json`

Подфаза не выделена — создайте `docs/phases/ML1-data-scan.md` при внедрении.
