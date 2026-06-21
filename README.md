# DevSecOps CI/CD Template

> **Start here:** `./scripts/adopt.sh --profile shift-left|oss-full|ai-ml --platform gitlab|github --target /path/to/repo` — see [docs/quickstart.md](docs/quickstart.md)

Шаблон мастер-плана и поэтапного внедрения DevSecOps CI/CD для **GitLab** и **GitHub** с целевым runtime **Kubernetes**.

Это reference-репозиторий: архитектура, документация, шаблоны job-файлов и политик gates. Для внедрения в свой проект используйте [`scripts/adopt.sh`](scripts/adopt.sh) и [profiles](templates/profiles/).

**Cursor:** отслеживайте выполнение в [`.cursor/plans/devsecops-execution.plan.md`](.cursor/plans/devsecops-execution.plan.md). Инструкции для агентов — [AGENTS.md](AGENTS.md).

## Быстрый старт

См. [docs/quickstart.md](docs/quickstart.md) — `adopt.sh`, profiles, validation, migration.

## Документация

| Документ | Содержание |
|----------|------------|
| [00-master-plan](docs/00-master-plan.md) | Сводный план, принципы, decision log |
| [01-sdlc-process](docs/01-sdlc-process.md) | SDLC, зоны, роли, trunk/bugfix |
| [02-pipeline-architecture](docs/02-pipeline-architecture.md) | Стадии CI/CD, gates, артефакты |
| [03-security-controls](docs/03-security-controls.md) | SAST, SCA, IaC, DAST, IAST, RASP, WAF |
| [04-tooling-catalog](docs/04-tooling-catalog.md) | Каталог инструментов по классам |
| [05-maturity-roadmap](docs/05-maturity-roadmap.md) | Кирилламида, miniRoadmap, фазы P0–F3 |
| [06-kubernetes-runtime](docs/06-kubernetes-runtime.md) | JCSF, admission, runtime, registry |
| [07-governance-and-docs](docs/07-governance-and-docs.md) | Регламенты и процессные документы |
| [08-compliance-gost-56939](docs/08-compliance-gost-56939.md) | Маппинг DAF → ГОСТ |
| [10-mlsecops-appendix](docs/10-mlsecops-appendix.md) | MLSecOps (опционально) |
| [11-ai-security-appendix](docs/11-ai-security-appendix.md) | AI security (опционально) |
| [quickstart](docs/quickstart.md) | Быстрый старт / миграция |
| [adoption-checklist](docs/adoption-checklist.md) | Чеклист внедрения |
| [platforms/gitlab](docs/platforms/gitlab.md) | Профиль GitLab CI |
| [platforms/gitlab-oss-full](docs/platforms/gitlab-oss-full.md) | GitLab OSS full |
| [platforms/github](docs/platforms/github.md) | Профиль GitHub Actions |
| [platforms/github-oss-full](docs/platforms/github-oss-full.md) | GitHub OSS full |
| [references/secure-sdlc-phases](docs/references/secure-sdlc-phases.md) | Secure SDLC 8 этапов |
| [references/sdlc-mapping](docs/references/sdlc-mapping.md) | Четыре модели SDLC |
| [references/sources](docs/references/sources.md) | Источники и атрибуция |
| [references/daf-kirillamida](docs/references/daf-kirillamida.md) | Уровни и поддомены DAF |
| [references/fintech-swimlane](docs/references/fintech-swimlane.md) | Swimlane финтех-PDF |
| [references/supplements](docs/references/supplements/) | Supplements: tools, финтех 12 этапов, JCSF overview |
| [references/framework-mappings](docs/references/framework-mappings.md) | SAMM/DSOMM/ГОСТ/CIS |

## Agent skills

Канон: [AGENTS.md](AGENTS.md) (индекс skills). Cursor stubs: `.cursor/skills/`.

## Roadmap подфаз

Сводка P0–F3: [docs/00-master-plan.md](docs/00-master-plan.md), [docs/05-maturity-roadmap.md](docs/05-maturity-roadmap.md). Детали: [docs/phases/](docs/phases/).

## Источники

Справочники и extracts в [docs/references/](docs/references/) (DAF, JCSF, Secure SDLC, финтех, tooling). Атрибуция: [docs/references/sources.md](docs/references/sources.md).

## Лицензия шаблона

Документация ссылается на открытые фреймворки Jet Security Team (DAF, JCSF). Соблюдайте их лицензии при коммерческом использовании.
