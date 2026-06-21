# P1 — Threat modeling (Plan)

## Цель

Secure SDLC **Plan**: threat model, misuse/abuse cases до начала разработки.

## DAF

- `P-REQ-TM-1-*` … `P-REQ-TM-4-1`
- Extract: [Практики.md](../references/extracts/daf/Практики.md) — `P-REQ-TM`

## Артефакты

- [templates/governance/threat-model-checklist.md](../../templates/governance/threat-model-checklist.md)
- Design doc / tracker ticket with link

## Связь с CI

Не CI job. Выход → тест-кейсы D2 (`tests/security/`), abuse scenarios в sec-func tests.

## Acceptance

- [ ] Checklist заполнен для новой фичи / сервиса
- [ ] Misuse/abuse cases → минимум 1 тест в `tests/security/`
- [ ] SecChamp sign-off до merge implementation MR

## Rollback

Process-only — удалить требование из Definition of Ready команды.
