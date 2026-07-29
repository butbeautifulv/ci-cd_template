# Mirror registry + artifact retention

## Container images

- Tag identity: `${SERVICE_NAME}-${SOURCE_SHA}` (immutable per source commit)
- Prefer GitLab Container Registry cleanup policies:
  - keep last N tags per service prefix
  - remove untagged / older than 90d (tune per capacity)
- Do **not** rely on hotfix tag deletion for image GC — images are not git tags

## CI artifacts

- `reports/**` expire_in: 30d (scans / junit)
- `build.env` expire_in: 1d
- `.mirror-sync-state.json` expire_in: 90d (sync job artifact / cache)

## Git tags hygiene

Obsolete debug tags (`*hotfix*`):

```bash
MIRROR_PROJECT_ID=1962 bash scripts/mirror-prune-hotfix-tags.sh --dry-run
MIRROR_PROJECT_ID=1962 bash scripts/mirror-prune-hotfix-tags.sh
```

Workflow already rejects new hotfix-matching tags.

## cleanup-runner vs tag prune

| Mechanism | Scope |
|-----------|--------|
| `cleanup-runner` job | Runner workspace + optional docker images matching `$REGISTRY` (not host-wide `-af`) |
| `mirror-prune-hotfix-tags.sh` | Git tags on the **mirror GitLab project** only |
| Registry cleanup policy | Container tags in GitLab/Nexus registry |

These are independent — do not confuse tag prune with runner disk cleanup.
