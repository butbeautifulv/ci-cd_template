# Источники и атрибуция

Материалы лежат в `.external/` (в `.gitignore`). Этот репозиторий — синтез, а не копия исходников.

## DevSecOps Assessment Framework (DAF)

- **Путь:** `.external/DevSecOps-Assessment-Framework-main/`
- **Автор:** [Jet Security Team](https://github.com/Jet-Security-Team/DevSecOps-Assessment-Framework)
- **Использовано:**
  - `DAF_public_RU.md` — полный текст практик
  - `DAF_MLSO_public_RU.md` — MLSecOps (см. [10-mlsecops-appendix.md](../10-mlsecops-appendix.md))
  - `DAF_public_RU.xlsx` — Кирилламида, miniRoadmap, Практики+MLSecOps, Документы DSO, FTE, SAMM/DSOMM/ГОСТ/BSIMM mappings
- **Синтез в repo:** [daf-kirillamida.md](daf-kirillamida.md), [framework-mappings.md](framework-mappings.md)
- **Лицензия:** см. `LICENSE` в каталоге DAF

## Jet Container Security Framework (JCSF)

- **Путь:** `.external/Jet-Container-Security-Framework-main/`
- **Использовано:** `JCSF v7_public.xlsx` (домены gen/nodes/orchr/man/img/cont/Dock, CIS, Приказ 118)
- **Синтез:** [06-kubernetes-runtime.md](../06-kubernetes-runtime.md)
- **Контакт:** dso@jet.su

## Типовой процесс безопасной разработки для финтеха

- **Файл:** `.external/Типовой_процесс_безопасной_разработки_для_финтеха.pdf`
- **Синтез:** [01-sdlc-process.md](../01-sdlc-process.md), [fintech-swimlane.md](fintech-swimlane.md)
- **Примечание:** PDF — схема; детали интерпретированы

## Карта инструментов DevSecOps

- **Файл:** `.external/Карта инструментов DevSecOps.pdf`
- **Синтез:** [04-tooling-catalog.md](../04-tooling-catalog.md)

## Cisco AI Defense (optional)

- **Файл:** `.external/CISCO_AI_DEFENCE.md`
- **Синтез:** [11-ai-security-appendix.md](../11-ai-security-appendix.md), [cisco-ai-defense.md](cisco-ai-defense.md)

## Нормативные ссылки (через DAF)

- ГОСТ Р 56939-2024 — [08-compliance-gost-56939.md](../08-compliance-gost-56939.md) (561 строк маппинга в xlsx)
- OWASP SAMM, DSOMM; BSIMM; CIS Kubernetes/Docker/Linux
- Профиль защиты ЦБ РФ (ПЗ ЦБ) — колонка в листе `Практики`

## Agent skills

Проектные skills в `.cursor/skills/` — синтез из `.external` и `docs/`. Старт: skill `devsecops-template`.

| Skill | Содержание |
|-------|------------|
| `devsecops-template` | Карта repo, правила, маршрутизация |
| `devsecops-external-sources` | xlsx/pdf + `extract_daf_xlsx.py` |
| `devsecops-daf` | Кирилламида, T-/P-поддомены |
| `devsecops-gost` | ГОСТ 56939 ↔ CI/CD |
| `devsecops-jcsf` | Домены JCSF, CIS, K8s |
| `devsecops-fintech-sdlc` | Swimlane финтех-PDF |
| `devsecops-tooling` | Инструменты по классам |
| `devsecops-governance` | Документы DSO, роли |
| `devsecops-phase-impl` | Подфазы P0–F3 |
| `devsecops-mlsecops` | ML/ИИ (опционально) |
| `devsecops-ai-security` | Cisco AI / skills (опционально) |

## Дисклеймер

В `.external/` — публичные версии фреймворков. Детальные опросники, how-to и отчёты аудита в DAF/JCSF — закрытая часть Jet Security Team.
