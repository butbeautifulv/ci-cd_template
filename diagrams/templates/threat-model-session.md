# Threat Modeling Session — Fabrica FastAPI

## System Information

| Field | Value |
|-------|-------|
| System Name | Fabrica FastAPI Reference API |
| Version/Release | |
| Owner | SecChamp |
| Date | |
| Participants | Dev, SecChamp, Architect |
| Methodology | [x] STRIDE [ ] LINDDUN [ ] CIA [ ] DIE |

## Scope Definition

**Assets to Protect:**

1. User credentials (PII)
2. JWT/OAuth2 tokens
3. Application configuration and secrets
4. Business data in PostgreSQL and S3

**Trust Boundaries:**

1. Internet → Application (FastAPI / Ingress)
2. Application → External Services (API, S3)
3. CI runner → Production cluster (see `pipeline_security.svg`)

**External Dependencies:**

1. External REST API (HTTPS/JSON)
2. S3 object storage
3. PostgreSQL

## Threat Register

Generate baseline: `python main.py --export stride-md -o out/`

| ID | Element | STRIDE Category | Threat Description | Severity | Status | Mitigation | Owner |
|----|---------|-----------------|-------------------|----------|--------|------------|-------|
| T-S-001 | | | | | [ ] Open [ ] Mitigated [ ] N/A | | |
| T-T-001 | | | | | [ ] Open [ ] Mitigated [ ] N/A | | |

## Action Items

| Item | Description | Owner | Due Date | Status |
|------|-------------|-------|----------|--------|
| 1 | Review DFD + C4 diagrams | SecChamp | | |
| 2 | Complete misuse/abuse cases | Dev | | |
| 3 | Map requirements to Fabrica gates | SecChamp | | |

## Review Schedule

- [ ] Initial threat model created (`python main.py --export all`)
- [ ] Peer review completed
- [ ] Architecture review board sign-off
- [ ] Quarterly review scheduled
- [ ] Model updated for last architecture change

## References

- Diagrams: [`../README.md`](../README.md)
- Veil playbook skill: `performing-threat-modeling-with-owasp-threat-dragon`
- Secure SDLC Plan: [`../../docs/references/secure-sdlc-phases.md`](../../docs/references/secure-sdlc-phases.md)
