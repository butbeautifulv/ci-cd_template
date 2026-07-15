# Источники и атрибуция

Исходные материалы **перенесены в репозиторий** (`docs/references/`). Vendor xlsx/pdf не коммитятся — только markdown extracts и синтез.

## DevSecOps Assessment Framework (DAF)

- **В repo:** [daf/](daf/) — `DAF_public_RU.md`, `DAF_MLSO_public_RU.md`, [LICENSE](daf/LICENSE)
- **Extracts:** [extracts/daf/](extracts/daf/) — листы xlsx (Кирилламида, Практики, ГОСТ56939_mapping, …)
- **Автор:** [Jet Security Team](https://github.com/Jet-Security-Team/DevSecOps-Assessment-Framework)
- **Синтез:** [daf-kirillamida.md](daf-kirillamida.md), [framework-mappings.md](framework-mappings.md)
- **Assets:** [assets/daf/](assets/daf/) — Heatmap, Pyramid of Maturity

## Jet Container Security Framework (JCSF)

- **Extracts:** [extracts/jcsf/](extracts/jcsf/)
- **Синтез:** [06-kubernetes-runtime.md](../06-kubernetes-runtime.md)
- **Assets:** [assets/jcsf/](assets/jcsf/)
- **Контакт:** dso@jet.su

## Типовой процесс безопасной разработки для финтеха

- **Archive:** [extracts/fintech-pdf.txt](extracts/fintech-pdf.txt)
- **Синтез:** [01-sdlc-process.md](../01-sdlc-process.md), [fintech-swimlane.md](fintech-swimlane.md)

## Карта инструментов DevSecOps

- **Archive:** [extracts/tools-map-pdf.txt](extracts/tools-map-pdf.txt)
- **Синтез:** [04-tooling-catalog.md](../04-tooling-catalog.md)

## Secure SDLC (8 этапов)

- **В repo:** [secure-sdlc-phases.md](secure-sdlc-phases.md), [sdlc-mapping.md](sdlc-mapping.md)

## Shared references (cxado meta-repo)

When using [cxado](https://github.com/butbeautifulv/cxado), JCSF/DAF vendor trees live at meta-repo root `refs/` ([cxado-references](https://github.com/butbeautifulv/cxado-references)). From fabrica: `../../refs/`.

Project-local `.external/` (fstec, chatgpt_mds, common-templates) remains gitignored and is **not** in cxado-references.

## Supplements (ChatGPT reinterpretations)

- **В repo:** [supplements/](supplements/) — structured MD views of tools map, fintech 12-stage process, JCSF practices overview
- **Optional local (gitignored):** `.external/chatgpt_mds/` — mirror only; do not commit
- **Canonical first:** [04-tooling-catalog.md](../04-tooling-catalog.md), [fintech-swimlane.md](fintech-swimlane.md), [extracts/jcsf/](extracts/jcsf/)

## Cisco AI Defense (optional)

- **В repo:** [cisco-ai-defense.md](cisco-ai-defense.md)
- **Синтез:** [11-ai-security-appendix.md](../11-ai-security-appendix.md)

## Нормативные ссылки (через DAF)

- ГОСТ Р 56939-2024 — [08-compliance-gost-56939.md](../08-compliance-gost-56939.md); extract [extracts/daf/ГОСТ56939_mapping.md](extracts/daf/ГОСТ56939_mapping.md)
- OWASP SAMM, DSOMM; BSIMM; CIS Kubernetes/Docker/Linux
- Профиль защиты ЦБ РФ (ПЗ ЦБ) — колонка в листе `Практики`

## Agent skills

Канон: `.agents/skills/`; Cursor discovery: `.cursor/skills/` stubs. Старт: `devsecops-template`. Полный индекс: [AGENTS.md](../../AGENTS.md).

## Дисклеймер

Публичные версии DAF/JCSF в repo. Детальные опросники, how-to и отчёты аудита — закрытая часть Jet Security Team.

## Legacy vendor cache

Опциональный локальный кэш vendor xlsx/pdf (gitignored) — только для re-extract; agents работают без него.
