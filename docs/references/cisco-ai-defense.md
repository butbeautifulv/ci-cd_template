# Cisco AI Defense — справочник

Источник: `.external/CISCO_AI_DEFENCE.md`

## Проекты (OSS)

| Project | Use in DevSecOps |
|---------|------------------|
| [Skill Scanner](https://github.com/cisco-ai-defense/skill-scanner) | Scan agent skills (`.cursor/skills/`) |
| [MCP Scanner](https://github.com/cisco-ai-defense/mcp-scanner) | MCP server configs |
| [A2A Scanner](https://github.com/cisco-ai-defense/a2a-scanner) | Agent-to-agent protocols |
| [AI BOM](https://github.com/cisco-ai-defense/aibom) | AI bill of materials |
| [Model Provenance Kit](https://github.com/cisco-ai-defense/model-provenance-kit) | Model lineage |
| [Pickle Fuzzer](https://github.com/cisco-ai-defense/pickle-fuzzer) | Unsafe pickle deserialization |
| [DefenseClaw](https://github.com/cisco-ai-defense/defenseclaw) | Agent governance |

## Framework

[Integrated AI Security and Safety Framework](https://arxiv.org/abs/2512.12921) — taxonomy for AI threats.

## Mapping to template

| Template phase | Cisco tool |
|----------------|------------|
| AI1 | skill-scanner |
| ML1 / MLSO | aibom, Presidio |
| Runtime | AI Defense enterprise / guardrails |

## Disclaimer

OSS tools complement enterprise Cisco AI Defense. Not required for standard app CI/CD.

См. [11-ai-security-appendix.md](../11-ai-security-appendix.md).
