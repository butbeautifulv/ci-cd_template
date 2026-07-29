# Mirror baseline inventory (manual, once)

First-time DefectDojo matrix by service@version without creating hotfix git tags.

## Prerequisites

- PAT with `read_api` on source group + `api` on mirror (`av.popov/map_objects-ci`, id **1962**)
- Fabrica checkout with `config/mirror-services.yaml`
- Mirror profile deployed (point-copy) with API workflow + Kaniko

## B0a — Inventory

```bash
export GITLAB_URL=https://gitlab.svo.aero
export GITLAB_PAT=…          # or SOURCE_GIT_TOKEN
export SOURCE_SSL_NO_VERIFY=1

python3 scripts/mirror-inventory-services.py
# optional YAML stub:
python3 scripts/mirror-inventory-services.py --yaml-stub > /tmp/mirror-stub.yaml
```

Default group: `dpm/airport_digital_ecosystem/map_objects` (+ parent siblings when `MIRROR_INVENTORY_SIBLINGS=1`).

## B0b — Registry

Merge reviewed rows into [`config/mirror-services.yaml`](../../config/mirror-services.yaml).

Optional fields:

| Field | Purpose |
|-------|---------|
| `openapi_path` | Spec path under `SCAN_ROOT` for Schemathesis |
| `api_base_url` | Live API target (or set CI var `API_BASE_URL`) |

## B0c — Trigger baseline pipelines

```bash
export MIRROR_PROJECT_ID=1962
export MIRROR_PIPELINE_REF=main
bash scripts/mirror-baseline-trigger.sh --dry-run
bash scripts/mirror-baseline-trigger.sh
```

Each pipeline gets variables `SERVICE_NAME` + `SOURCE_REF` (= `source_ref_fallback`). **No git tags.**

Low concurrency: script sleeps 2s between creates. For floods, run dry-run and trigger manually per service.

## B0d — DefectDojo matrix

After pipelines finish:

- Product name = `SERVICE_NAME` (from resolve)
- Engagement/version aligns with resolved `SOURCE_REF` / SHA
- Controls: secrets, SAST, OSA, IaC, SCA, and **fuzzing** only when OpenAPI + `API_BASE_URL` present

Record pipeline IDs in [`mirror-security-pipeline-action-log.md`](mirror-security-pipeline-action-log.md).

## Prefer after Kaniko + Schemathesis

Run the baseline wave after T3 (Kaniko) is on the mirror; include T5 fuzz only for services with known `api_base_url`.

## Ongoing (not baseline)

Use schedule `sync-sources` or API:

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_PAT" \
  --header "Content-Type: application/json" \
  --data '{"ref":"main","variables":[
    {"key":"SERVICE_NAME","value":"hwa_service"},
    {"key":"SOURCE_REF","value":"<sha-or-tag>"}
  ]}' \
  "$GITLAB_URL/api/v4/projects/1962/pipeline"
```

Do **not** create `*-hotfix*` tags. Workflow rejects tags matching `/hotfix/i`.
