# Security functional tests (D2)

Automated security tests run in CI via `sec-func-tests` job.

## Setup

```bash
pip install pytest requests
export PREPROD_URL=https://preprod.example.com
pytest tests/security/ -v
```

## Coverage target

- DAF `T-PREPROD-SECTEST-2-2`: ≥5% automated
- F3 target: 20%

## Suggested tests

| Test | Category |
|------|----------|
| Security headers | Config |
| Auth on admin routes | AuthZ |
| Session cookie flags | Session |
| CORS policy | API |
| Rate limiting smoke | Abuse |

Add application-specific tests alongside `test_security_baseline.py`.
