# Misuse and Abuse Cases — FastAPI Reference

Misuse cases: legitimate user actions that violate security policy.  
Abuse cases: attacker actions exploiting design weaknesses.

## FastAPI / Auth

| ID | Type | Scenario | Component | Expected control |
|----|------|----------|-----------|------------------|
| MU-001 | Misuse | User shares admin API key in chat | Auth | B1 secrets, education |
| AB-001 | Abuse | Stolen JWT replay until expiry | Auth / OAuth2 | Short TTL, refresh rotation, D2 |
| AB-002 | Abuse | Broken access control via query param | Auth | B2 SAST, D2 sec-func-tests |

**Fabrica demo:** [`examples/sample-app/app/main.py`](../../examples/sample-app/app/main.py) — `/admin?key=secret` (intentional weak auth for scanner demos).

## Input / API

| ID | Type | Scenario | Component | Expected control |
|----|------|----------|-----------|------------------|
| AB-003 | Abuse | SQL injection via unvalidated field | Pydantic / PostgreSQL | B2 SAST, parameterized queries |
| AB-004 | Abuse | Mass assignment via extra JSON fields | Pydantic models | Strict schemas, B2 |
| AB-005 | Abuse | OpenAPI `/docs` exposes internal schema in preprod | OpenAPI | Disable in prod, network policy |

## Outbound / Integration

| ID | Type | Scenario | Component | Expected control |
|----|------|----------|-----------|------------------|
| AB-006 | Abuse | SSRF via `httpx` to `169.254.169.254` | HTTP Client | URL allowlist, B2, D1 DAST |
| AB-007 | Abuse | Credential stuffing on login endpoint | Auth | Rate limit, MFA, D2 |

## Configuration / Secrets

| ID | Type | Scenario | Component | Expected control |
|----|------|----------|-----------|------------------|
| MU-002 | Misuse | Secret committed to git | Settings | B1 secret-scan |
| AB-008 | Abuse | Env vars leaked via error handler or `/docs` | Settings | Safe errors, B1, B2 |

## API fuzzing reference

Use [`examples/openapi/minimal.yaml`](../../examples/openapi/minimal.yaml) with D1 API fuzz (Schemathesis) after preprod deploy.

## Workshop prompts

1. Which abuse cases apply to your service's `/admin` or privileged routes?
2. Is `/docs` reachable from the internet in preprod? In prod?
3. What outbound URLs does `httpx` allow? Document allowlist.
