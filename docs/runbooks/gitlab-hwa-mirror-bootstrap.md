# GitLab mirror bootstrap for service pipelines

Runbook for launching service pipelines in a dedicated GitLab mirror project when source project permissions are read-only/viewer.

## Scope

- Source project: `dpm/airport_digital_ecosystem/map_objects` (read-only).
- CI target: mirror project (example `av.popov/map_objects-ci`).
- Trigger model (preferred): API/web/schedule with `SERVICE_NAME` + `SOURCE_REF` — see [`mirror-api-trigger-schemathesis.md`](mirror-api-trigger-schemathesis.md). **Do not** create `*-hotfix*` tags.
- Release tags still allowed: `<service_name>/vX.Y.Z` (hotfix banned in workflow).
- Baseline once: [`mirror-baseline-inventory.md`](mirror-baseline-inventory.md).
- Registry of services: [`config/mirror-services.yaml`](../../config/mirror-services.yaml) + [`scripts/resolve-mirror-service.sh`](../../scripts/resolve-mirror-service.sh).

## Phase P0.1 — access bootstrap

1. Configure SSH key for the single GitLab account.
2. Create a PAT with minimum scopes required for mirror automation:
   - `read_repository`
   - `write_repository`
   - `read_api`
   - `api` (required to manage CI/CD variables and project setup)
3. Run bootstrap check:

```bash
chmod +x scripts/gitlab-check-access-bootstrap.sh
GITLAB_HOST=gitlab.svo.aero \
GITLAB_URL=https://gitlab.svo.aero \
GITLAB_PROJECT_PATH=av.popov/map_objects-ci \
GITLAB_PAT="$GITLAB_PAT" \
bash scripts/gitlab-check-access-bootstrap.sh
```

Success criteria:
- SSH handshake to `git@<gitlab-host>` succeeds.
- PAT validates `/api/v4/user`.
- Mirror project API is reachable (or expected warning if not created yet).

## Phase P0.2 — mirror project bootstrap

1. Create mirror project `map_objects-ci` (group/project where the account has write access).
2. Enable Container Registry and Pipelines.
3. Set default artifact retention to keep storage pressure low (recommended 7-14 days).
4. Configure protected tag policy for release tags:
   - allow creating tags only for maintainers/automation account.

Optional API bootstrap helper:

```bash
chmod +x scripts/gitlab-bootstrap-mirror-project.sh
GITLAB_URL=https://gitlab.svo.aero \
GITLAB_PAT="$GITLAB_PAT" \
GROUP_ID=1234 \
PROJECT_NAME=map_objects-ci \
DRY_RUN=true \
bash scripts/gitlab-bootstrap-mirror-project.sh
```

## Phase P0.3 — tag sync contract

Use tag-only sync for any service:

```bash
chmod +x scripts/gitlab-sync-service-tags.sh
SOURCE_REMOTE=source \
MIRROR_REMOTE=mirror \
SERVICE_NAME=hwa_service \
TAG_REGEX='^hwa_service/v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$' \
DRY_RUN=true \
bash scripts/gitlab-sync-service-tags.sh
```

Then run without `DRY_RUN` to push tags.

Contract:
- only tags matching `<service_name>/v*` are mirrored;
- pipeline should not run for branch pushes;
- if a tag does not include required service artifacts (Dockerfile/manifests), job exits with explicit reason.

## Phase P1.1/P1.2/P1.3 — pipeline profile (point-copy)

Use profile:
- `templates/profiles/oss-full-service-mirror.gitlab-ci.yml`

This profile provides:
- tag-driven workflow only;
- static security checks + ASPM static upload wave;
- image build + combined SCA/SBOM + ASPM image upload;
- Nexus-only images/pip/rules (corp offline).

### Primary deploy path: point-copy (not adopt)

When the mirror already has `.gitlab/jobs/`, **do not** run `adopt.sh` — it copies `templates/gitlab/jobs` *into* that directory and nests `.gitlab/jobs/jobs`.

Use the helper (preferred):

```bash
bash scripts/point-copy-mirror.sh --target /path/to/map_objects-ci
# or pack + scp to jump host, then apply under /tmp/map_objects-ci
```

Manual equivalent:
1. Copy changed job YAMLs into `.gitlab/jobs/...` (same relative layout).
2. Copy scripts under `scripts/`, config under `config/` as needed.
3. Write `.gitlab-ci.yml` from the mirror profile with includes rewritten:
   - `local: '/templates/gitlab/jobs/` → `local: '.gitlab/jobs/`
4. `python3 -c 'import yaml; yaml.safe_load(open(".gitlab-ci.yml"))'`

Fresh empty target only (no `.gitlab/jobs` yet) may still use:

```bash
./scripts/adopt.sh --profile oss-full-service-mirror --platform gitlab --target /path/to/map_objects-ci
```

If `.gitlab/jobs` already exists, `adopt.sh` refuses unless `--force` (still prefer point-copy).

## Phase P1.4 — cleanup/retention guardrails

Included cleanup job:
- `templates/gitlab/jobs/oss/cleanup-runner.yml`

Behavior:
- runs `when: always` in `post-deploy` stage for tag pipelines;
- prunes stopped containers and **job/registry-tagged** images (not host-wide `-af` on shared shell);
- deletes local temp/cache folders that the job owns.

## Phase P2.1 — CI/CD variables checklist

Configure in the mirror project (masked/protected as appropriate):

| Variable | Required | Notes |
|----------|----------|-------|
| `SOURCE_GIT_TOKEN` | yes | Clone/archive real service repos |
| `NEXUS_USER` / `NEXUS_PASSWORD` | yes | Docker proxy + Trivy DB OCI + auth-gated PyPI |
| `PIP_INDEX_URL` | yes | Nexus PyPI simple URL (no pypi.org) |
| `PIP_TRUSTED_HOST` | recommended | Host part of Nexus PyPI |
| `DEFECTDOJO_URL` | yes | From **shell/P30**: `https://<NODE_IP>:30808` (not in-cluster DNS) |
| `DEFECTDOJO_API_TOKEN` | yes | Masked |
| `DEFECTDOJO_INSECURE` | mirror | `true` until corp CA mounted on runners |
| `DEFECTDOJO_FAIL_ON_ERROR` | mirror | `true` — refuse soft-green empty UI |
| `DEFECTDOJO_ENGAGEMENT` | no | Default `CI/CD` (shared); **product** = service name |

Exporter:
- `scripts/aspm-export.py`
- `config/aspm-export.yaml`

Runner notes: [`docs/runbooks/corp-gitlab-runner.md`](corp-gitlab-runner.md).

## Phase P2.2 — pilot runs

Run three tag-based pilots:

1. **Pilot A**: static checks + ASPM static upload.
2. **Pilot B**: full pipeline with build + SCA/SBOM + image upload.
3. **Pilot C**: repeated release tag (or patch tag) to verify reimport and cleanup stability.

API trigger helper:

```bash
chmod +x scripts/gitlab-run-service-pilots.sh
GITLAB_URL=https://gitlab.svo.aero \
GITLAB_PAT="$GITLAB_PAT" \
PROJECT_ID=12345 \
SERVICE_NAME=hwa_service \
DRY_RUN=true \
bash scripts/gitlab-run-service-pilots.sh
```

Expected outputs:
- security artifacts in GitLab jobs;
- findings uploaded to DefectDojo (import/reimport) under product = **service name**;
- no persistent runner resource leaks after `cleanup-runner`.

## Phase P2.3 — scale to next services (onboarding contract)

Do **not** rewrite `SERVICE_PATH` per service for map_objects-style monorepo tags.

For the next service:

1. Append an entry to [`config/mirror-services.yaml`](../../config/mirror-services.yaml):
   - `project_id`, `repo_url`, `source_ref_fallback`
2. Ensure `SERVICE_TAG_REGEX` in the mirror profile covers the new prefix (or keep the multi-service regex).
3. Point-copy updated `config/` + scripts into the mirror.
4. Trigger via API (preferred) or release tag `<service>/vX.Y.Z` — **not** hotfix tags:
   ```bash
   # SERVICE_NAME + SOURCE_REF → see mirror-api-trigger-schemathesis.md
   ```
   Verify:
   - `[resolve] service=… product=…`
   - DefectDojo product equals the service name
   - Kaniko `IMAGE_TAG=${SERVICE_NAME}-${SOURCE_SHA}`
   - Schemathesis skip or junit when OpenAPI + `API_BASE_URL` set

Keep the same profile contract and reuse static/image ASPM waves. Immutable core = job templates + profile; mutable = YAML registry + CI vars.
