#!/bin/sh
# Emit PIP_INDEX_URL with Nexus basic auth when NEXUS_USER/PASSWORD are set.
# Usage: eval "$(sh scripts/pip-index-auth.sh)"  → sets PIP_INDEX_AUTH
# Or:    INDEX=$(sh scripts/pip-index-auth.sh) && pip install -i "$INDEX" ...
set -eu
RAW="${PIP_INDEX_URL:?PIP_INDEX_URL required}"
case "$RAW" in
  *://*:*@*)
    # already has userinfo
    printf '%s\n' "$RAW"
    exit 0
    ;;
esac
if [ -z "${NEXUS_USER:-}" ] || [ -z "${NEXUS_PASSWORD:-}" ]; then
  printf '%s\n' "$RAW"
  exit 0
fi
# Prefer python url-quote (passwords may contain @:/)
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY'
import os
from urllib.parse import quote, urlparse, urlunparse
raw = os.environ["PIP_INDEX_URL"]
user = quote(os.environ["NEXUS_USER"], safe="")
pw = quote(os.environ["NEXUS_PASSWORD"], safe="")
u = urlparse(raw)
netloc = f"{user}:{pw}@{u.hostname}" + (f":{u.port}" if u.port else "")
print(urlunparse((u.scheme, netloc, u.path, u.params, u.query, u.fragment)))
PY
  exit 0
fi
# Fallback: no quote (works for simple passwords)
REST="${RAW#*://}"
SCHEME="${RAW%%://*}"
printf '%s\n' "${SCHEME}://${NEXUS_USER}:${NEXUS_PASSWORD}@${REST}"
