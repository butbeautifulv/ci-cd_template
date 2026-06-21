# Governance и процессные документы

Структура из листа **«Документы для процессов DSO»** (`DAF_public_RU.xlsx`).

## Обязательный минимум

| № | Документ | Ключевые разделы |
|---|----------|------------------|
| 1 | Положение по безопасной разработке ПО | ЖЦ, роли, требования по этапам (3.1–3.9) |
| 2 | Регламент процесса безопасной разработки | Процессы 4.1–4.14 (SAST, SCA, DAST, секреты, сборка…) |
| 3 | Регламент управления уязвимостями | Triage, SLA, ASTO, исключения |
| 4 | Стандарты конфигурации приложений | `P-REQ-STDR-App` |
| 5 | Стандарты конфигурации инфраструктуры | `P-REQ-STDR-Infr`, IaC |
| 6 | Методика threat modeling | `P-REQ-TM` |

## Процессные домены DAF (P-*)

| Поддомен | Содержание | Артефакт в org |
|----------|------------|----------------|
| `P-EDU-AWR` | Обучение, осведомлённость | План обучения, e-learning |
| `P-EDU-KB` | База знаний DSO | Wiki, playbooks |
| `P-REQ-TM` | Threat modeling | Шаблон TM, taint analysis |
| `P-REQ-RD` | Требования ИБ к ПО | Security requirements |
| `P-REQ-CR` | Контроль выполнения требований | Чеклисты в MR |
| `P-REQ-STDR-App` | Стандарты приложений | Secure coding guide |
| `P-REQ-STDR-Infr` | Стандарты инфраструктуры | Baseline K8s/IaC |
| `P-DEFECT-MNG` | Управление дефектами ИБ | SLA, workflow в трекере |
| `P-DEFECT-CNS` | Консолидация (ASTO) | DefectDojo / ASPM |
| `P-MET-SET` | Метрики ИБ | KPI dashboard |
| `P-MET-EX` | Контроль метрик | Quarterly review |
| `P-ROLE-SC` | Security Champions | Назначение SecChamp |
| `P-ROLE-RESP` | Роли и ответственность | RACI-матрица |

Справочник: [references/daf-kirillamida.md](references/daf-kirillamida.md).

## Регламент безопасной разработки (оглавление)

1. Общие положения
2. Функциональные роли
3. Жизненный цикл безопасной разработки
4. Процессы:
   - 4.4 Композиционный анализ (SCA)
   - 4.7 Статический анализ (SAST)
   - 4.9 Безопасность конфигураций (IaC)
   - 4.10 Динамический анализ (DAST)
   - 4.12 Функциональное ИБ-тестирование
   - 4.13 Pentest
   - 4.14 Управление дефектами ИБ (ASTO)

## Матрица ролей

| Роль | RACI в CI/CD |
|------|--------------|
| Разработчик | R: исправление findings |
| SecChamp | A: triage, approve security exceptions |
| AppSec / Аналитик ИБ | C: политики scanners, DAST |
| DevOps | R: pipeline, deploy |
| QA | R: sec func tests, fuzzing |
| PO / PM | I: приоритизация, риск |
| Инженер эксплуатации | R: prod, WAF, K8s |

## Security Champions

`P-ROLE-SC` — по одному SecChamp на команду (подфаза roadmap DAF: Q+1).

## Связь с CI/CD

| Процесс | Артефакт в repo |
|---------|-----------------|
| SAST | `jobs/sast.*`, policy `sast:` |
| Управление дефектами | SARIF → DefectDojo / трекер |
| Метрики | Pipeline badges, Dependency-Track |
| Release | [release-gate-checklist.md](release-gate-checklist.md) |

## Отчёт аудита DAF

Шаблон разделов: текущие процессы, сильные/слабые стороны, рекомендации по этапам ЖЦ. Heatmap: `images/Heatmap.png` в DAF repo. FTE: листы `FTE AppSec`, `Расчет FTE DSO` в xlsx.

См. [references/framework-mappings.md](references/framework-mappings.md).
