#!/usr/bin/env bash
# Delete obsolete *-hotfix* tags on the mirror project (hygiene after API-trigger migration).
#   GITLAB_PAT=… MIRROR_PROJECT_ID=1962 bash scripts/mirror-prune-hotfix-tags.sh [--dry-run]
set -euo pipefail

GL="${GITLAB_URL:-https://gitlab.svo.aero}"
API="${CI_API_V4_URL:-$GL/api/v4}"
API="${API%/}"
case "$API" in */api/v4) ;; *) API="$API/api/v4" ;; esac
TOKEN="${GITLAB_PAT:-${SOURCE_GIT_TOKEN:-${PRIVATE_TOKEN:-}}}"
PROJECT_ID="${MIRROR_PROJECT_ID:-${CI_PROJECT_ID:-}}"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) echo "Usage: mirror-prune-hotfix-tags.sh [--dry-run]"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

[[ -n "$TOKEN" ]] || { echo "ERROR: GITLAB_PAT required"; exit 1; }
[[ -n "$PROJECT_ID" ]] || { echo "ERROR: MIRROR_PROJECT_ID required"; exit 1; }

export API TOKEN PROJECT_ID DRY_RUN SOURCE_SSL_NO_VERIFY="${SOURCE_SSL_NO_VERIFY:-1}"

python3 <<'PY'
import json, os, ssl, urllib.parse, urllib.request

api = os.environ["API"]
tok = os.environ["TOKEN"]
pid = os.environ["PROJECT_ID"]
dry = os.environ.get("DRY_RUN", "0") == "1"
ctx = ssl.create_default_context()
if os.environ.get("SOURCE_SSL_NO_VERIFY", "1") in ("1", "true", "TRUE"):
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

def get(url):
    req = urllib.request.Request(url, headers={"PRIVATE-TOKEN": tok})
    with urllib.request.urlopen(req, context=ctx, timeout=60) as r:
        return json.load(r)

def delete(url):
    req = urllib.request.Request(url, headers={"PRIVATE-TOKEN": tok}, method="DELETE")
    with urllib.request.urlopen(req, context=ctx, timeout=60) as r:
        return r.status

page = 1
deleted = 0
while True:
    tags = get(f"{api}/projects/{pid}/repository/tags?per_page=100&page={page}")
    if not isinstance(tags, list) or not tags:
        break
    for t in tags:
        name = t.get("name") or ""
        if "hotfix" not in name.lower():
            continue
        print(f"[prune] {'would delete' if dry else 'delete'} tag={name}")
        if not dry:
            enc = urllib.parse.quote(name, safe="")
            try:
                delete(f"{api}/projects/{pid}/repository/tags/{enc}")
                deleted += 1
            except Exception as e:
                print(f"[prune] WARN failed {name}: {e}")
    if len(tags) < 100:
        break
    page += 1
print(f"[prune] done deleted={deleted} dry_run={dry}")
PY
