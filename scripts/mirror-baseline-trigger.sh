#!/usr/bin/env bash
# Create GitLab pipelines on the mirror for each service in mirror-services.yaml.
#   GITLAB_PAT=… MIRROR_PROJECT_ID=1962 bash scripts/mirror-baseline-trigger.sh [--dry-run]
# No git tags. Variables: SERVICE_NAME, SOURCE_REF (= source_ref_fallback).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REG="${MIRROR_SERVICES:-$ROOT/config/mirror-services.yaml}"
GL="${GITLAB_URL:-https://gitlab.svo.aero}"
API="${CI_API_V4_URL:-$GL/api/v4}"
API="${API%/}"
case "$API" in */api/v4) ;; *) API="$API/api/v4" ;; esac
TOKEN="${GITLAB_PAT:-${SOURCE_GIT_TOKEN:-${PRIVATE_TOKEN:-}}}"
PROJECT_ID="${MIRROR_PROJECT_ID:-${CI_PROJECT_ID:-}}"
REF="${MIRROR_PIPELINE_REF:-}"
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --ref) REF="$2"; shift 2 ;;
    -h|--help) echo "Usage: mirror-baseline-trigger.sh [--dry-run] [--ref master]"; exit 0 ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

[[ -n "$TOKEN" ]] || { echo "ERROR: GITLAB_PAT required"; exit 1; }
[[ -n "$PROJECT_ID" ]] || { echo "ERROR: MIRROR_PROJECT_ID required"; exit 1; }
[[ -f "$REG" ]] || { echo "ERROR: missing $REG"; exit 1; }

# Auto-detect default branch when --ref / MIRROR_PIPELINE_REF unset.
if [[ -z "$REF" ]]; then
  REF=$(python3 - "$API" "$TOKEN" "$PROJECT_ID" <<'PY'
import json, os, ssl, sys, urllib.request
api, tok, pid = sys.argv[1:4]
ctx = ssl.create_default_context()
if os.environ.get("SOURCE_SSL_NO_VERIFY", "1") in ("1", "true", "TRUE"):
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
req = urllib.request.Request(f"{api}/projects/{pid}", headers={"PRIVATE-TOKEN": tok})
with urllib.request.urlopen(req, context=ctx, timeout=60) as r:
    print(json.load(r).get("default_branch") or "main")
PY
)
fi
REF="${REF:-main}"

mapfile -t SERVICES < <(awk '
  /^services:/{s=1; next}
  s && /^  [a-zA-Z0-9_]+:[[:space:]]*$/ {
    if (name != "" && fb != "") print name "\t" fb
    name=$1; sub(/:$/,"",name); fb=""
    next
  }
  s && /source_ref_fallback:/ {
    line=$0; sub(/.*source_ref_fallback:[[:space:]]*/,"",line)
    gsub(/["'\'']/,"",line); gsub(/[[:space:]]+$/,"",line); fb=line
  }
  s && /^[^ ]/{ if (name != "" && fb != "") print name "\t" fb; s=0 }
  END { if (name != "" && fb != "") print name "\t" fb }
' "$REG")

for row in "${SERVICES[@]}"; do
  name="${row%%$'\t'*}"
  sref="${row#*$'\t'}"
  echo "[baseline] SERVICE_NAME=$name SOURCE_REF=$sref pipeline_ref=$REF"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    continue
  fi
  python3 - "$API" "$TOKEN" "$PROJECT_ID" "$REF" "$name" "$sref" <<'PY'
import json, ssl, sys, urllib.request
api, tok, pid, ref, name, sref = sys.argv[1:7]
body = json.dumps({
    "ref": ref,
    "variables": [
        {"key": "SERVICE_NAME", "value": name},
        {"key": "SOURCE_REF", "value": sref},
    ],
}).encode()
ctx = ssl.create_default_context()
import os
if os.environ.get("SOURCE_SSL_NO_VERIFY", "1") in ("1", "true", "TRUE"):
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
req = urllib.request.Request(
    f"{api}/projects/{pid}/pipeline",
    data=body,
    headers={"PRIVATE-TOKEN": tok, "Content-Type": "application/json"},
    method="POST",
)
with urllib.request.urlopen(req, context=ctx, timeout=60) as r:
    p = json.load(r)
print(f"  pipeline id={p.get('id')} status={p.get('status')} url={p.get('web_url')}")
PY
  sleep 2
done

echo "[baseline] done count=${#SERVICES[@]}"
