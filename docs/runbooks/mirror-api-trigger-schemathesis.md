# Mirror API trigger + Schemathesis (no hotfix tags)

## Preferred trigger

Create a pipeline with variables (not a debug git tag):

```bash
curl --request POST \
  --header "PRIVATE-TOKEN: $GITLAB_PAT" \
  --header "Content-Type: application/json" \
  --data '{"ref":"main","variables":[
    {"key":"SERVICE_NAME","value":"hwa_service"},
    {"key":"SOURCE_REF","value":"0.0.4"}
  ]}' \
  "https://gitlab.svo.aero/api/v4/projects/1962/pipeline"
```

Optional: `OPENAPI_PATH`, `API_BASE_URL`, `API_FUZZ_HEADER_*` (auth).

## Banned

- Tags matching `hotfix` (case-insensitive) — workflow `when: never`
- Manual `git tag -f …-hotfix*` spam for rescans

Release tags `<service>/vX.Y.Z` remain allowed for formal releases.

## Sync poll

Job `sync-sources` (schedule or `MIRROR_SYNC=1`) runs `scripts/mirror-sync-sources.py`:

- Reads `config/mirror-services.yaml`
- Compares latest commit SHA per `source_ref_fallback` to `.mirror-sync-state.json`
- Creates API pipeline on change
- Dedupes running/pending pipelines with same `SERVICE_NAME` + `SOURCE_REF`

## Kaniko

`build-image` uses Nexus Kaniko (`OSS_KANIKO_IMAGE`). No dind / `DOCKER_HOST`.

- `IMAGE_TAG=${SERVICE_NAME}-${SOURCE_SHA}`
- Fallback: `FROM $BUILD_BASE_IMAGE` → `BUILD_FALLBACK=1`

## Schemathesis (T5)

Job `api-fuzz-schemathesis` after build/SCA:

| Condition | Behavior |
|-----------|----------|
| OpenAPI found (`openapi_path` or discover under `SCAN_ROOT`) + `API_BASE_URL` set | `schemathesis run` → `reports/schemathesis-junit.xml` → DD control `fuzzing` |
| Missing OpenAPI | log `[fuzz] skip — no OpenAPI`; exit 0 |
| Missing `API_BASE_URL` | log skip; exit 0 |
| `BUILD_FALLBACK=1` | skip (base image ≠ app API) |

Nexus image only — **no apt**. Pin: `OSS_SCHEMATHESIS_IMAGE`.

Auth: document headers via CI vars when first services need JWT/cookies (`API_FUZZ_HEADERS` / hooks file). Empty = unauthenticated only.

## Binary fuzz (T6 backlog)

AFL / Go / Jazzer via existing Fabrica jobs — **deferred** until Schemathesis path is green. Not part of this mirror wave.

## Retention / prune

See [`mirror-registry-retention.md`](mirror-registry-retention.md) and `scripts/mirror-prune-hotfix-tags.sh`.
