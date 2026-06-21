# AI3 — RAG / runtime guardrails (doc-only)

## Goal

Operate-stage controls for RAG, vector DB, inference — **no default CI gate**.

## Tools (optional)

- [Adversarial Hubness Detector](https://github.com/cisco-ai-defense/adversarial-hubness-detector)
- Cisco AI Defense platform / guardrails

## Files

- [docs/runbooks/ai-runtime-guardrails.md](../runbooks/ai-runtime-guardrails.md)
- `docs/phases/AI3-rag-runtime.md`

## Secure SDLC

**Operate** / **Monitor** — process and runtime, not MR pipeline.

## Acceptance

- [ ] Runbook reviewed for prod inference
- [ ] Hubness audit scheduled for RAG indices (manual)
