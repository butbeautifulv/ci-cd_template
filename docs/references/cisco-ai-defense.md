# Cisco AI Defense — справочник

Источник: [Cisco AI Defense OSS](https://github.com/cisco-ai-defense) (архив в репозитории перенесён в этот документ).

## Проекты (OSS)

### Agent & MCP Security

| Project | Use in DevSecOps |
|---------|------------------|
| [DefenseClaw](https://github.com/cisco-ai-defense/defenseclaw) | Agent governance — scan/enforce skills, MCP, plugins |
| [MCP Scanner](https://github.com/cisco-ai-defense/mcp-scanner) | MCP server threat analysis |
| [Skill Scanner](https://github.com/cisco-ai-defense/skill-scanner) | Scan agent skills (`.cursor/skills/`, `.agents/skills/`) |
| [A2A Scanner](https://github.com/cisco-ai-defense/a2a-scanner) | Agent-to-agent protocols |

### AI Supply Chain & Model Security

| Project | Use in DevSecOps |
|---------|------------------|
| [AI BOM](https://github.com/cisco-ai-defense/aibom) | AI bill of materials |
| [Model Provenance Kit](https://github.com/cisco-ai-defense/model-provenance-kit) | Model lineage / base-model detection |
| [Pickle Fuzzer](https://github.com/cisco-ai-defense/pickle-fuzzer) | Unsafe pickle deserialization |
| [Adversarial Hubness Detector](https://github.com/cisco-ai-defense/adversarial-hubness-detector) | RAG / vector DB audit |

### ML & Developer Tools

| Project | Use in DevSecOps |
|---------|------------------|
| [SecureBERT 2](https://github.com/cisco-ai-defense/securebert2) | Cybersecurity NLP — NER, vuln detection |
| [Python SDK](https://github.com/cisco-ai-defense/ai-defense-python-sdk) | Platform integration |
| [IDE AI Security Scanner](https://cisco-ai-defense.github.io/docs/ai-security-scanner) | VS Code — MCP/skills scan, CodeGuard |
| [AI Defense Hybrid](https://github.com/cisco-ai-defense/ai-defense-hybrid) | Hybrid deploy on AWS EKS |

## Framework

[Integrated AI Security and Safety Framework](https://arxiv.org/abs/2512.12921) — lifecycle-aware taxonomy for AI threats; operationalized via [AIUC-1](https://blogs.cisco.com/ai/aiuc-1-operationalizes-ciscos-ai-security-framework).

[Model Provenance Constitution](https://github.com/cisco-ai-defense/model-provenance-kit/blob/main/docs/constitution/model_provenance_constitution.md) — provenance relationships between ML models.

## Mapping to template

| Template phase | Cisco tool |
|----------------|------------|
| AI1 | skill-scanner, mcp-scanner |
| ML1 / MLSO | aibom, model-provenance-kit |
| Runtime | AI Defense enterprise / guardrails |

## Disclaimer

OSS tools complement enterprise Cisco AI Defense. Not required for standard app CI/CD.

См. [11-ai-security-appendix.md](../11-ai-security-appendix.md).
