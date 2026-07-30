# Mirror baseline inventory + Wave-3 fleet + ASPM HTML

First-time / wave DefectDojo matrix by service@version **without** creating hotfix git tags.

## Prerequisites

- PAT with `read_api` on source group + `api` on mirror (`av.popov/map_objects-ci`, id **1962**)
- Fabrica checkout with `config/mirror-services.yaml`
- Mirror profile deployed (point-copy) with API workflow + Kaniko + **inline ASPM** (`aspm-export-ci.sh`)
- For HTML batch: `DEFECTDOJO_URL` + `DEFECTDOJO_API_TOKEN` (+ `DEFECTDOJO_INSECURE=true` on corp)

## Inventory → review → registry

```bash
export GITLAB_URL=https://gitlab.svo.aero
export GITLAB_PAT=…
export SOURCE_SSL_NO_VERIFY=1

python3 scripts/mirror-inventory-services.py
python3 scripts/mirror-inventory-services.py --yaml-stub > /tmp/mirror-stub.yaml
# stubs are enabled:false / tier:candidate — review before merge
```

Merge reviewed rows into [`config/mirror-services.yaml`](../../config/mirror-services.yaml).

| Field | Purpose |
|-------|---------|
| `enabled` | Fleet/sync skip when `false` |
| `tier` | `pilot` \| `core` \| `candidate` \| `skip` |
| `openapi_path` / `api_base_url` | Schemathesis / DAST |
| deploy_* | Ephemeral deploy (pilots: hwa / data_lake / user) |

**API fleet does not need `SERVICE_TAG_REGEX`.** Expand that regex only when adding **tag-driven** services.

## Offline dry-run

```bash
make mirror-fleet-dry
# or Wave-3 only:
python3 scripts/mirror-fleet-trigger.py --dry-run --wave3
```

## Wave-3 live fleet

Services: `hwa_service`, `data_lake_service`, `user_service` (pilots). Core candidates stay `enabled: false`.

```bash
export MIRROR_PROJECT_ID=1962
export MIRROR_PIPELINE_REF=master   # or main — auto-detect if unset
make mirror-fleet CONCURRENCY=1
# artifact: reports/mirror-fleet-last.jsonl
```

Each pipeline gets `SERVICE_NAME` + `SOURCE_REF` (= `source_ref_fallback`). **No git tags.** Start concurrency 1; bump to 2 only after a green wave.

Legacy wrapper (same as enabled-only fleet):

```bash
bash scripts/mirror-baseline-trigger.sh --dry-run
```

## After pipelines — ASPM HTML (final step)

Wait until Wave-3 pipelines finish (inline after_script uploads to DefectDojo). Then:

```bash
export DEFECTDOJO_URL=…
export DEFECTDOJO_API_TOKEN=…
export DEFECTDOJO_INSECURE=true
make mirror-aspm-html
# → reports/aspm-report-<service>.html
```

See [`defectdojo-aspm-report.md`](defectdojo-aspm-report.md).

## Ongoing sync (schedule)

`sync-sources` job / `scripts/mirror-sync-sources.py` uses the same `load_services` parser and **skips `enabled: false`**.

## Anti-patterns

- Do **not** push commits/tags to activate all services.
- Do **not** create `*-hotfix*` tags (workflow rejects `/hotfix/i`).
- Do **not** reintroduce separate `upload-*-to-dojo` jobs on mirror.

Record pipeline IDs + HTML paths in [`mirror-security-pipeline-action-log.md`](mirror-security-pipeline-action-log.md).
