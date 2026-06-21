# Кирилламида DAF — справочник

Источник: лист `Кирилламида` в `DAF_public_RU.xlsx`, [DAF README](.external/DevSecOps-Assessment-Framework-main/README.md).

## Уровни зрелости

| № | Название | Смысл для CI/CD |
|---|----------|-----------------|
| 0 | Хаос | Ad-hoc, нет формализации |
| 1 | Минимальный | Первые инструменты, узкое покрытие |
| 2 | Базовый | Целевой старт: SCM, CI, базовые сканы |
| 3 | Повышенный | MR gates, автоматизация |
| 4 | Продвинутый | SBOM, image scan, DAST |
| 5 | Развитый | Signing, K8s runtime, процессы |
| 6 | Экспертный | IAST, passive prod, Red Team |
| 7 | Космический | Максимальная зрелость |

## Алгоритм выбора целевого уровня

1. По умолчанию — **Базовый** (уровень 2).
2. Уровни 0–2 на 80–100% → цель **Повышенный** или **Продвинутый**.
3. 0–2 на 80%+, но 3–5 < 80% где-либо → **Развитый**.
4. 0–5 на 80%+ → **Экспертный** или **Космический**.

## Поддомены (технологии)

| ID | Поддомен |
|----|----------|
| T-ADI-DEP | Контроль сторонних компонентов |
| T-ADI-ART | Управление артефактами |
| T-DEV-COMP | Защита рабочих мест |
| T-DEV-SM | Защита секретов (dev) |
| T-DEV-BLD | Защита build-среды |
| T-DEV-SCM | Защита SCM |
| T-DEV-SRC | Контроль изменений в коде |
| T-DEV-CICD | Защита CI/CD |
| T-CODE-SPC | Безопасность заказной разработки |
| T-CODE-SST | SAST |
| T-CODE-SC | SCA |
| T-CODE-IMG | Анализ образов |
| T-CODE-SECDN | Идентификация секретов |
| T-CODE-DOCKERFS | Dockerfile |
| T-PREPROD-DAST | DAST preprod |
| T-PREPROD-PENTEST | Pentest preprod |
| T-PREPROD-VULN | Vuln scan preprod infra |
| T-PREPROD-SECTEST | Функциональное ИБ-тестирование |
| T-PREPROD-MANSEC | IaC / манифесты |
| T-PROD-SM | Секреты prod |
| T-PROD-DAST | DAST prod |
| T-PROD-PENTEST | Pentest prod |
| T-PROD-ACCESS | IaC / доступ к инфраструктуре |
| T-PROD-NETWORK | Сетевой контроль L4–L7 |
| T-PROD-RUN | Runtime policies |
| T-PROD-VULN | Vuln scan prod |
| T-PROD-EVENTS | События ИБ / SIEM |

## Поддомены (процессы)

| ID | Поддомен |
|----|----------|
| P-EDU-AWR | Обучение и осведомлённость |
| P-EDU-KB | База знаний DSO |
| P-REQ-TM | Threat modeling |
| P-REQ-RD | Требования ИБ к ПО |
| P-REQ-CR | Контроль выполнения требований |
| P-REQ-STDR-App | Стандарты конфигурации приложений |
| P-REQ-STDR-Infr | Стандарты конфигурации инфраструктуры |
| P-DEFECT-MNG | Управление дефектами ИБ |
| P-DEFECT-CNS | Консолидация дефектов |
| P-MET-SET | Метрики ИБ |
| P-MET-EX | Контроль метрик |
| P-ROLE-SC | Security Champions |
| P-ROLE-RESP | Роли и ответственность |

Полный текст практик: `.external/.../DAF_public_RU.md`.
