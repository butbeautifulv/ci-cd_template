# MLSecOps — опциональное приложение

Источник: [daf/DAF_MLSO_public_RU.md](references/daf/DAF_MLSO_public_RU.md), extract [extracts/daf/Практики_MLSecOps.md](references/extracts/daf/Практики_MLSecOps.md).

Не входит в базовый CI/CD шаблон (фазы P0–F3). Подключайте профилем **`ai-ml`**.

## Phase docs

| Phase | Doc | Gate |
|-------|-----|------|
| ML1 | [phases/ML1-data-scan.md](phases/ML1-data-scan.md) | PII **block** |
| ML2 | [phases/ML2-ml-bom.md](phases/ML2-ml-bom.md) | ML-BOM warn |
| ML3 | [phases/ML3-model-scan.md](phases/ML3-model-scan.md) | manual warn |

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

```bash
./scripts/adopt.sh --profile ai-ml --platform gitlab --target .
```

Jobs: `ml-data-scan`, `ml-bom`, `ml-model-scan` + AI jobs — см. [11-ai-security-appendix.md](11-ai-security-appendix.md).

Demo: [examples/sample-ml-app/](examples/sample-ml-app/).
