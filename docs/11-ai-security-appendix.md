# AI Security appendix (optional)

Синтез [Cisco AI Defense](references/cisco-ai-defense.md) + [10-mlsecops-appendix.md](10-mlsecops-appendix.md).

Не входит в базовый P0–F3. Подключайте при AI agents, MCP, LLM apps.

## Угрозы (Integrated AI Security Framework)

| Класс | Примеры | Контроль |
|-------|---------|----------|
| Agent/MCP | Malicious skills, poisoned MCP | Skill Scanner, MCP Scanner |
| Supply chain | Model provenance, pickle bombs | AI BOM, Pickle Fuzzer |
| RAG/Vector | Adversarial hubs | Hubness Detector |
| Runtime | Prompt injection | AI Defense platform / guardrails |

## CI/CD integration

| Job | Когда | Gate |
|-----|-------|------|
| `skill-scanner` | MR changes `.cursor/skills/` | warn |
| `mcp-scan` | MR changes MCP configs | warn |
| `aibom` | Build ML artifact | artifact |
| `ml-data-scan` | MR datasets | block PII (MLSO) |

## Фазы

- **AI1** — skill/MCP scan ([phases/AI1-skill-scan.md](phases/AI1-skill-scan.md))
- **ML1** — MLSecOps data ([10-mlsecops-appendix.md](10-mlsecops-appendix.md))

## Skill

Cursor: `devsecops-ai-security`
