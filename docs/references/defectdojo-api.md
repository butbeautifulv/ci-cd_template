# DefectDojo API v2 (reference)

OpenAPI spec (local): [`.external/DefectDojo API v2.json`](../../.external/DefectDojo%20API%20v2.json)

Official docs: [DefectDojo API](https://defectdojo.github.io/django-DefectDojo/integrations/api-v2-docs/)

## Endpoints used by this template

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v2/import-scan/` | POST | First import into Product/Engagement/Test |
| `/api/v2/reimport-scan/` | POST | Re-import with deduplication (default in CI) |

Auth header: `Authorization: Token <API_KEY>`

Content-Type: `multipart/form-data` with fields + `file` upload.

## scan_type mapping (oss-full)

| Control | Report | DefectDojo `scan_type` | `test_title` |
|---------|--------|------------------------|--------------|
| secrets | `gitleaks.sarif` | Gitleaks Scan | secrets |
| sast | `semgrep.sarif` | SARIF | sast-semgrep |
| osa | `osa.sarif` | SARIF | osa-trivy-fs |
| sca | `sca.sarif` | SARIF | sca-trivy-image |
| iac | `reports/checkov.sarif` | SARIF | iac-checkov |
| dockerfile | `hadolint.sarif` | SARIF | dockerfile-hadolint |
| linters | `linter.sarif` | SARIF | linters |
| dast | `reports/zap-api.xml` | ZAP Scan | dast-zap |
| fuzzing | `reports/schemathesis-junit.xml` → Generic JSON | Generic Findings Import | api-fuzz-schemathesis |

Configured in [`config/aspm-export.yaml`](../../config/aspm-export.yaml).

## CLI

```bash
python3 scripts/aspm-export.py --control sast --report semgrep.sarif --dry-run
```

See [runbooks/aspm-export.md](../runbooks/aspm-export.md).
