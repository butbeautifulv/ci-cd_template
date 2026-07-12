# Taint Analysis Checklist — FastAPI DFD

Closes Fabrica design gap: **Taint analysis** (`03-security-controls.md`, DAF `P-REQ-TM`).

Track untrusted data from **sources** (entries) to **sinks** (sensitive operations).

## Sources (entries)

| ID | Source | Data class | STRIDE | Notes |
|----|--------|------------|--------|-------|
| TA-S-01 | User → Auth (credentials) | PII | S, I | LINDDUN on linkability |
| TA-S-02 | External API → DataProcessing (response) | PUBLIC | T, I | Validate schema |
| TA-S-03 | Config → Auth (settings) | SECRET | I | No secrets in logs |
| TA-S-04 | HTTP request body/query | PUBLIC/PII | T, I | Pydantic boundary |

## Sinks (sensitive operations)

| ID | Sink | Risk if tainted input reaches | Fabrica control |
|----|------|------------------------------|-----------------|
| TA-K-01 | PostgreSQL query | SQL injection | B2, D1 |
| TA-K-02 | S3 upload path/key | Path traversal, overwrite | B2, B4 |
| TA-K-03 | httpx outbound URL | SSRF | B2, D1 |
| TA-K-04 | JWT issue/validate | Token forgery | B2, D2 |
| TA-K-05 | Log / audit output | Info disclosure | B1, B2 |
| TA-K-06 | OpenAPI /docs render | Schema disclosure | Process, D1 |

## Flow review (from DFD)

| Flow | Source → Sink path | Sanitizer / validator | Status |
|------|---------------------|----------------------|--------|
| User → Auth → DataProcessing | TA-S-01 → TA-K-04, TA-K-01 | OAuth2, Pydantic | [ ] |
| DataProcessing → External API | TA-S-04 → TA-K-03 | URL allowlist, httpx | [ ] |
| DataProcessing → FileHandler → S3 | TA-S-04 → TA-K-02 | Path validation | [ ] |
| Config → Auth | TA-S-03 → TA-K-04 | pydantic-settings | [ ] |

## Checklist

- [ ] Every source mapped to at least one sink path
- [ ] Validators documented on each cross-boundary flow
- [ ] No path from external input to sink without validation
- [ ] SAST rules cover identified sources (B2)
- [ ] DAST/fuzz covers API entry points (D1)
- [ ] SecChamp sign-off before B-phase merge

## Generate baseline elements

```bash
python main.py --export stride-md -o out/
```

Cross-reference: [`diagrams/model.py`](../diagrams/model.py) (`FASTAPI_DFD_FLOWS`).
