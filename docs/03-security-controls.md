# Матрица контролей безопасности

Центральный справочник контролей DevSecOps CI/CD.

## Сводная матрица

| Контроль | SDLC-точка | Что сканируем | DAF | JCSF | Шаблон job | Статус |
|----------|------------|---------------|-----|------|-------------|--------|
| **Linters** | IDE, MR | Style + security rules | `T-DEV-SRC` | — | custom / Code-Quality | baseline |
| **SAST** | IDE, MR, nightly | Исходный код | `T-CODE-SST` | — | `jobs/sast.*` | baseline |
| **Secret scan** | SCM, MR | Код, IaC | `T-CODE-SECDN` | — | `jobs/secret-scan.*` | baseline |
| **OSA/SCA** | MR, build, runtime | Зависимости, SBOM | `T-CODE-SC`, `T-ADI-DEP` | — | `jobs/sca.*` | baseline |
| **IaC scan** | MR, pre-deploy | tf, k8s, helm | `T-PREPROD-MANSEC` | `man` | `jobs/iac-scan.*` | baseline |
| **Dockerfile** | MR (paths) | Dockerfile | `T-CODE-DOCKERFS` | `Dock` | `jobs/dockerfile-lint.*` | baseline |
| **Container scan** | Build, registry | Образы CVE | `T-CODE-IMG` | `img` | `jobs/container-scan.*` | C2 |
| **SBOM** | Build | CycloneDX | `T-ADI-ART-3-1` | — | `jobs/sbom.*` | C1 |
| **Signing** | Build | cosign | `T-ADI-ART-4-*` | — | `jobs/sign.*` | C4 |
| **DAST** | Preprod | Web/API | `T-PREPROD-DAST` | — | `jobs/dast.*` | D1 |
| **Fuzzing** | QA | Бинарники, API | финтех-PDF | — | doc / optional job | out-of-base |
| **Sec func tests** | Preprod | Auth, headers | `T-PREPROD-SECTEST` | — | `jobs/sec-func-tests.*` | D2 |
| **IAST** | Preprod | Runtime app | финтех-PDF | — | `jobs/iast-preprod.*` | F1 optional |
| **ASTO** | Все этапы | SARIF агрегация | `P-DEFECT-CNS` | — | DefectDojo / ASPM | process |
| **WAF/API** | Prod edge | L7, API | `T-PROD-NETWORK` | Gen L4/L7 | runbook F2 | out-of-CI |
| **RASP** | Prod runtime | Атаки в app | `T-PROD-EVENTS` | `cont` | runbook F2 | out-of-CI |
| **K8s admission** | Prod deploy | Pods, policies | `T-PROD-RUN` | `orchr` | `k8s/admission/` | E1 |
| **Network policy** | Prod | L4 pod traffic | `T-PROD-NETWORK` | `gen` | `k8s/network/` | E2 |
| **CWPP/Falco** | Prod | Syscalls, exec | `T-PROD-EVENTS` | `cont` | `k8s/runtime/` | E3 |
| **Taint analysis** | Design | Поверхность атаки | `P-REQ-TM` | — | SecChamp tool | design |

## Уровни внедрения

| Уровень | Описание |
|---------|----------|
| **Минимум** | B1–B3 warn; SCM hardening A1 |
| **Рекомендуется** | B1–B5 block critical/high; C1–C2; D1; ASTO triage |
| **Продвинутый** | C4 signing; E1–E4; F1–F3; fuzzing в QA |

## Политика gates

Единый файл: [config/security-gate-policy.yaml](../config/security-gate-policy.yaml).

| Severity | MR default | main default |
|----------|------------|--------------|
| critical | block | block |
| high | block | block |
| medium | warn | warn |
| low | info | info |

## Управление дефектами (ASTO)

| Практика | Реализация |
|----------|------------|
| `P-DEFECT-MNG` | SLA в трекере, SecChamp triage |
| `P-DEFECT-CNS` | SARIF → DefectDojo / Jit / AppSec.Track |
| Размеченный SAST | SecChamp помечает false positive до merge |

## Ignore-файлы

Контроль обхода сканеров (`T-DEV-SRC-3-6`):

- Изменения `.semgrepignore`, `.gitleaksignore`, `.trivyignore` — review SecChamp + CODEOWNERS.
- Запрет silent skip без тикета.

## Инструменты

См. [04-tooling-catalog.md](04-tooling-catalog.md).

## IAST / RASP / WAF

Не выделены отдельными поддоменами DAF — **расширение из финтех-процесса**, маппинг:

- IAST → `T-PREPROD-DAST-3-3` (бизнес-логика в тестах)
- RASP → `T-PROD-EVENTS-3-1`, JCSF **cont**
- WAF → `T-PROD-NETWORK-2-2`

Runbooks: [phases/F2-rasp-waf.md](phases/F2-rasp-waf.md).
