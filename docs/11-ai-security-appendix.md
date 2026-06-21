# AI Security appendix (optional)

Синтез [Cisco AI Defense](references/cisco-ai-defense.md) + [10-mlsecops-appendix.md](10-mlsecops-appendix.md).

Не входит в базовый P0–F3. Подключайте профилем **`ai-ml`**.

## Угрозы (Integrated AI Security Framework)

| Класс | Примеры | Контроль |
|-------|---------|----------|
| Agent/MCP | Malicious skills, poisoned MCP | Skill Scanner, MCP Scanner |
| Supply chain | Model provenance, pickle bombs | AI BOM, Pickle scan |
| RAG/Vector | Adversarial hubs | Hubness Detector (manual) |
| Runtime | Prompt injection | [ai-runtime-guardrails.md](runbooks/ai-runtime-guardrails.md) |

## CI/CD integration (profile ai-ml)

| Job | Phase | Gate |
|-----|-------|------|
| `skill-scanner` | AI1 | warn |
| `mcp-scan` | AI1 | warn |
| `aibom` | AI2 | warn |
| `pickle-scan` | AI2 | warn |
| `ml-data-scan` | ML1 | **block PII** |
| `ml-bom` | ML2 | warn |
| `ml-model-scan` | ML3 | manual warn |

## Adopt

```bash
./scripts/adopt.sh --profile ai-ml --platform gitlab --target .
```

## Фазы

- **AI1** — [phases/AI1-skill-scan.md](phases/AI1-skill-scan.md)
- **AI2** — [phases/AI2-ai-supply-chain.md](phases/AI2-ai-supply-chain.md)
- **AI3** — [phases/AI3-rag-runtime.md](phases/AI3-rag-runtime.md)
- **ML1–ML3** — [10-mlsecops-appendix.md](10-mlsecops-appendix.md)

## Skill

`devsecops-ai-security`, `devsecops-mlsecops`

Demo: [examples/sample-ml-app/](examples/sample-ml-app/)
