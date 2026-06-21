# DevSecOps CI/CD Template

> **Start here:** `./scripts/adopt.sh --profile shift-left --platform gitlab|github --target /path/to/repo` — see [docs/quickstart.md](docs/quickstart.md)

Шаблон мастер-плана и поэтапного внедрения DevSecOps CI/CD для **GitLab** и **GitHub** с целевым runtime **Kubernetes**.

Это reference-репозиторий: архитектура, документация, шаблоны job-файлов и политик gates. Для внедрения в свой проект используйте [`scripts/adopt.sh`](scripts/adopt.sh) и [profiles](templates/profiles/).

**Cursor:** отслеживайте выполнение в [`.cursor/plans/devsecops-execution.plan.md`](.cursor/plans/devsecops-execution.plan.md). Инструкции для агентов — [AGENTS.md](AGENTS.md).

## Быстрый старт

1. Прочитайте [docs/00-master-plan.md](docs/00-master-plan.md).
2. Оцените зрелость по [docs/05-maturity-roadmap.md](docs/05-maturity-roadmap.md).
3. Внедряйте подфазы из [docs/phases/](docs/phases/) — **один PR на подфазу**.
4. Скопируйте CI в свой репозиторий:
   - GitLab: `templates/gitlab/.gitlab-ci.yml` → корень + `templates/gitlab/jobs/`
   - GitHub: `templates/github/workflows/` → `.github/workflows/`
5. Настройте [config/security-gate-policy.yaml](config/security-gate-policy.yaml) под свою политику ИБ.

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
| [platforms/github](docs/platforms/github.md) | Профиль GitHub Actions |
| [references/sources](docs/references/sources.md) | Источники и атрибуция |
| [references/daf-kirillamida](docs/references/daf-kirillamida.md) | Уровни и поддомены DAF |
| [references/fintech-swimlane](docs/references/fintech-swimlane.md) | Swimlane финтех-PDF |
| [references/framework-mappings](docs/references/framework-mappings.md) | SAMM/DSOMM/ГОСТ/CIS |

## Agent skills

Проектные skills в `.cursor/skills/`:

| Skill | Назначение |
|-------|------------|
| `devsecops-template` | Точка входа, карта repo |
| `devsecops-external-sources` | Чтение `.external`, скрипт xlsx |
| `devsecops-daf` | Кирилламида, практики DAF |
| `devsecops-gost` | ГОСТ 56939 ↔ pipeline |
| `devsecops-jcsf` | K8s/container security |
| `devsecops-fintech-sdlc` | Финтех swimlane, MR gates |
| `devsecops-tooling` | Каталог инструментов |
| `devsecops-governance` | Регламенты DSO, ASTO |
| `devsecops-phase-impl` | Внедрение подфаз (≤5 files/PR) |
| `devsecops-mlsecops` | MLSecOps (опционально) |
| `devsecops-ai-security` | Cisco AI / skill scan (опционально) |

## Roadmap подфаз

| Фаза | Подфазы | Фокус |
|------|---------|-------|
| P0 | Scaffold | Документация |
| A | A1–A2 | SCM + CI base |
| B | B1–B5 | Shift-left: secrets, SAST, SCA, IaC, Dockerfile |
| C | C1–C4 | Supply chain: SBOM, image scan, registry, signing |
| D | D1–D3 | Preprod: DAST, sec tests, pentest gate |
| E | E1–E4 | K8s runtime: admission, network, Falco, SIEM |
| F | F1–F3 | IAST, WAF/RASP, advanced assurance |

Детали: [docs/phases/](docs/phases/).

## Источники

Материалы в `.external/` (не коммитятся): DAF, JCSF, типовой финтех-процесс, карта инструментов DevSecOps. См. [docs/references/sources.md](docs/references/sources.md).

## Лицензия шаблона

Документация ссылается на открытые фреймворки Jet Security Team (DAF, JCSF). Соблюдайте их лицензии при коммерческом использовании.
