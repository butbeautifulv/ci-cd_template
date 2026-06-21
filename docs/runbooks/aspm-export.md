# ASPM / ASTO findings export

Export pipeline scan results to **DefectDojo** (or noop when not configured).

DAF practice: `P-DEFECT-CNS` — consolidation of SAST/DAST/SCA findings.

## Architecture

- Config: [`config/aspm-export.yaml`](../../config/aspm-export.yaml)
- CLI: [`scripts/aspm-export.py`](../../scripts/aspm-export.py)
- GitLab snippet: [`.gitlab/jobs/aspm/export-after-script.yml`](../../templates/gitlab/jobs/aspm/export-after-script.yml)
- Profile **`oss-full`**: per-scan upload in `after_script` of each scanner job

## DefectDojo setup

1. Create API token: User → API Key
2. Product will be auto-created if `auto_create_context: true` (default)
3. Engagement name default: `CI/CD` (override via `DEFECTDOJO_ENGAGEMENT`)

## GitLab CI variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DEFECTDOJO_URL` | yes | Base URL, e.g. `https://defectdojo.corp.example` |
| `DEFECTDOJO_API_TOKEN` | yes | API token (masked, protected) |
| `DEFECTDOJO_PRODUCT_NAME` | no | Default `$CI_PROJECT_NAME` |
| `DEFECTDOJO_ENGAGEMENT` | no | Default `CI/CD` |
| `DEFECTDOJO_FAIL_ON_ERROR` | no | `true` to fail job on upload error (default `false`) |

Without `DEFECTDOJO_URL` — export is **noop** (exit 0).

## Import vs reimport

Default: **`reimport-scan`** — deduplicates findings per Test. First pipeline run creates Product/Engagement/Test via `auto_create_context`.

To force first-time import only, set in `config/aspm-export.yaml`:

```yaml
defectdojo:
  reimport: false
```

## Local test

```bash
export DEFECTDOJO_URL=https://defectdojo.example
export DEFECTDOJO_API_TOKEN=your-token
python3 scripts/aspm-export.py --control secrets --report gitleaks.sarif --dry-run
```

## Manual upload (curl)

```bash
curl -X POST "${DEFECTDOJO_URL}/api/v2/reimport-scan/" \
  -H "Authorization: Token ${DEFECTDOJO_API_TOKEN}" \
  -F "scan_type=SARIF" \
  -F "test_title=sast-semgrep" \
  -F "product_name=myapp" \
  -F "engagement_name=CI/CD" \
  -F "auto_create_context=true" \
  -F "minimum_severity=Info" \
  -F "file=@semgrep.sarif"
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Upload skipped | Set `DEFECTDOJO_URL` in CI/CD variables |
| HTTP 401 | Check `DEFECTDOJO_API_TOKEN` |
| Unknown scan_type | Update mapping in `aspm-export.yaml` |
| python3 not found (ZAP/hadolint jobs) | Job installs python3 in `after_script` before export |

## Related

- [defectdojo-api.md](../references/defectdojo-api.md)
- [03-security-controls.md](../03-security-controls.md) — ASTO row
- [gitlab-oss-full.md](../platforms/gitlab-oss-full.md)
