# SDLC и процесс безопасной разработки

Интерпретация типового финтех-процесса (PDF) с привязкой к доменам DAF.

Детальная swimlane-схема: [references/fintech-swimlane.md](references/fintech-swimlane.md).

## Зоны и среды

| Зона | Данные | Контроли |
|------|--------|----------|
| DEV / feature branch | Синтетические / обезличенные | IDE SAST, линтеры, pre-commit, MR pipeline |
| QA / тестирование | Синтетические | Unit, fuzzing, sanitizers, SAST triage |
| UAT / preprod | Специально подготовленные тестовые | DAST, IAST, code coverage + DAST, sec func tests, pentest |
| PROD | Реальные | WAF, RASP, CWPP, passive DAST, SBOM monitor |
| **Зона управления ИБ** | — | Политики, ASTO, IRM/GRC, triage |

Допускается **отдельное окружение на feature branch** (финтех-PDF).

## Поток (trunk-based)

1. **Планирование** — риски, требования ИБ (`P-REQ-RD-*`), threat model (`P-REQ-TM-*`).
2. **Дизайн** — поверхность атаки; **Taint Analysis Tool** для уточнения (SecChamp).
3. **Разработка** — код в SCM, задача в трекере привязана к MR (`T-DEV-SRC-2-5`).
4. **MR/PR** — Security Gate (параллельно):
   - SAST (лёгкий в IDE + полный в CI)
   - **Линтеры** (style + security)
   - Secret-check
   - Лишние/запрещённые файлы
   - SCA (после SBOM на сборке — gate «не стало хуже»)
   - IaC scan
   - Code review + SecChamp triage
5. **Сборка** — централизованные шаблоны CI, SBOM, image scan, подпись (C-фазы); **размеченный отчёт SAST**.
6. **QA** — unit, **fuzzing** (AFL++, Jazzer), **concolic**, **sanitizers** (ASan, Valgrind), тесты утечек ПДн.
7. **Preprod** — deploy, DAST, IAST, автотесты ИБ, нагрузочное тестирование.
8. **Release** — pentest gate (критичные системы), SecChamp approve.
9. **Prod** — CD, WAF/API policies, admission, RASP, мониторинг.
10. **Эксплуатация** — **ASTO** (агрегация SAST/DAST/SCA), **IRM/GRC**, OBOM+SBOM monitor, SIEM.

## Роли

| Роль | Ответственность |
|------|-----------------|
| Разработчик | Код, unit-тесты, исправление findings |
| SecChamp | Triage SAST/SCA, taint analysis, security review MR |
| Аналитик ИБ | Требования, DAST сценарии, pentest |
| QA | Функциональные, fuzzing, security func tests |
| DevOps | CI/CD, deploy, registry, шаблонизация конвейеров |
| PO / PM | Приоритизация, принятие риска |
| Инженер эксплуатации | Prod deploy, WAF, K8s policies |
| Инженер ИБ (контроллер) | Политики эксплуатации, ASTO, IRM |

## Управление дефектами

- `P-DEFECT-MNG` — triage, SLA, исключения в трекере
- `P-DEFECT-CNS` — **ASTO** (DefectDojo, AppSec.Track, Jit): единая воронка из SARIF
- Все артефакты по задаче — в трекере (комментарий на схеме PDF)

## Особые режимы

### Bugfix fast-path

- Упрощённый Security Gate (минимум: secrets + SCA critical).
- Принятие риска в тикете; полные проверки — post-merge в срок N дней.
- Пропуск UAT по согласованию (`T-DEV-SRC-2-2` — исключения документировать).

### Trunk-based

- Короткоживущие ветки; merge только через MR с зелёными checks.
- Linear history, squash/rebase (`T-DEV-SRC-1-4`).
- Допускается принятие риска с отложенными проверками (PDF).

## Артефакты по этапам

| Этап | Артефакты |
|------|-----------|
| Design | Требования ИБ, архитектура, поверхность атаки, threat model |
| MR | SARIF (SAST/SCA/secrets), линтер-отчёты, комментарии review |
| QA | Fuzzing seeds, coverage reports, sanitizer logs |
| Build | SBOM, образ, scan reports, подпись |
| Release | Подписанные артефакты, pentest report (при необходимости) |
| Prod | OBOM/SBOM в мониторинге, журналы SIEM, RASP/WAF events |

## Связанные документы

- [02-pipeline-architecture.md](02-pipeline-architecture.md)
- [07-governance-and-docs.md](07-governance-and-docs.md)
- [10-mlsecops-appendix.md](10-mlsecops-appendix.md) — при ML/ИИ
- [release-gate-checklist.md](release-gate-checklist.md)
