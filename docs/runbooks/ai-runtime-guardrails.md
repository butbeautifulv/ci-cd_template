# AI runtime guardrails (Operate)

Secure SDLC **Operate** — inference, RAG, prompt injection response.

## Checklist

| Area | Action |
|------|--------|
| Prompt injection | Input/output filters; log suspicious prompts |
| RAG | Periodic hubness audit on vector index |
| Model serving | AuthN/Z on inference API; rate limits |
| Secrets | No API keys in prompts or logs |
| Monitoring | SIEM alerts on guardrail blocks (E4) |

## Hubness / RAG audit

1. Export embedding index snapshot
2. Run [Adversarial Hubness Detector](https://github.com/cisco-ai-defense/adversarial-hubness-detector) (manual)
3. Triage anomalous clusters → ticket

## Prompt injection runbook

1. Alert from guardrail / WAF / app logs
2. Capture prompt + session id (no PII in ticket)
3. SecChamp + ML owner triage
4. Patch system prompt / filter rules
5. Regression test in preprod

## Out of CI

Enterprise Cisco AI Defense platform — optional; not required for template CI.

См. [AI3-rag-runtime.md](../phases/AI3-rag-runtime.md).
