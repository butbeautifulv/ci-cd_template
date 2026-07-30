# ASPM / ASTO findings export

Export pipeline scan results to **DefectDojo** (or noop when not configured).

DAF practice: `P-DEFECT-CNS` — consolidation of SAST/DAST/SCA findings.

## Architecture

- Config: [`config/aspm-export.yaml`](../../config/aspm-export.yaml)
- CLI: [`scripts/aspm-export.py`](../../scripts/aspm-export.py)
- CI entry (preferred): [`scripts/aspm-export-ci.sh`](../../scripts/aspm-export-ci.sh) — skip/resolve/python|docker fallback
- GitLab snippet: [`templates/gitlab/jobs/aspm/export-after-script.yml`](../../templates/gitlab/jobs/aspm/export-after-script.yml)
- Profiles **`oss-full-service-mirror`** and **`oss-full`**: **one job per control** — scan in `script`, DefectDojo upload in `after_script` via `aspm-export-ci.sh`
- Legacy `upload-*-to-dojo` jobs / stages `static-security-upload` / `image-security-upload` are **removed** from those profiles (files kept deprecated for old forks)

```yaml
semgrep-sast:
  variables:
    ASPM_CONTROL: sast
    ASPM_REPORT: semgrep.sarif
  script:
    - # … scan …
  after_script:
    - sh scripts/aspm-export-ci.sh
```

DAST/fuzz set `ASPM_SKIP_EMPTY=false` so Dojo still gets a Test when the report has zero alerts.

## DefectDojo setup

1. Create API token: User → API Key
2. Product will be auto-created if `auto_create_context: true` (default)
3. Engagement name default: `CI/CD` (override via `DEFECTDOJO_ENGAGEMENT`)

### Mirror multi-service naming

- **Product** = service name from the release tag (`hwa_service`, `data_lake_service`, `user_service`), set by [`scripts/resolve-mirror-service.sh`](../../scripts/resolve-mirror-service.sh) from [`config/mirror-services.yaml`](../../config/mirror-services.yaml).
- **Engagement** stays shared: `CI/CD` (do not create one engagement per service).
- Historical uploads under product `map_objects-ci` remain; new pipelines must log `[aspm] product=<service>` — not the mirror project name.

## GitLab CI variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DEFECTDOJO_URL` | yes | Base URL reachable from the **runner** (see below) |
| `DEFECTDOJO_API_TOKEN` | yes | API token (masked, protected) |
| `DEFECTDOJO_PRODUCT_NAME` | no | Default `$CI_PROJECT_NAME` (exporter falls back if unset). **Mirror multi-service:** set to service name from tag via `scripts/resolve-mirror-service.sh` (e.g. `hwa_service`), not the mirror project name |
| `DEFECTDOJO_PRODUCT_TYPE` | no | Product type for auto-create (default `Research`) |
| `DEFECTDOJO_ENGAGEMENT` | no | Default `CI/CD` (keep shared across services; product distinguishes them) |
| `DEFECTDOJO_FAIL_ON_ERROR` | no | `true` to fail job on upload error (default `false`; mirror profile sets `true`) |
| `DEFECTDOJO_INSECURE` | no | `true` to skip TLS verify (NodePort self-signed / corp MITM) |

Without `DEFECTDOJO_URL` — export is **noop** (exit 0).

### Which URL for which runner

| Runner location | `DEFECTDOJO_URL` |
|-----------------|------------------|
| K8s pod with cluster DNS | `http://defectdojo.cxado-aspm.svc.cluster.local:8080` |
| Shell / host outside cluster (P30 mirror) | `https://<P30_NODE_IP>:30808` (TLS gateway; set `DEFECTDOJO_INSECURE=true`) |

Do **not** use in-cluster DNS from shell runners — soft-green skips or network errors, empty DD UI.

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
