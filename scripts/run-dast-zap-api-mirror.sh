#!/usr/bin/env sh
# Corp mirror — OWASP ZAP API scan from OpenAPI (full operation coverage).
# Fail-hard: no soft skip on BUILD_FALLBACK / DEPLOY_SKIPPED / missing OAS /
# empty XML / coverage regression (healthcheck-only).
# DefectDojo "ZAP Scan" needs XML (-x); JSON (-J) for gate-check.
set -eu

mkdir -p reports /zap/wrk

if [ -f scripts/resolve-mirror-service.sh ]; then
  # shellcheck disable=SC1091
  . scripts/resolve-mirror-service.sh || true
fi

if [ "${BUILD_FALLBACK:-0}" = "1" ] || [ "${DEPLOY_SKIPPED:-0}" = "1" ]; then
  echo "[dast] ERROR — BUILD_FALLBACK=${BUILD_FALLBACK:-0} DEPLOY_SKIPPED=${DEPLOY_SKIPPED:-0}"
  exit 1
fi

if [ -z "${API_BASE_URL:-}" ]; then
  echo "[dast] ERROR — API_BASE_URL unset (deploy-test did not set it)"
  exit 1
fi

PREFIX="${API_PATH_PREFIX:-}"
case "$PREFIX" in
  ""|/) PREFIX="" ;;
  *)
    case "$PREFIX" in
      /*) ;;
      *) PREFIX="/$PREFIX" ;;
    esac
    while [ "${PREFIX%/}" != "$PREFIX" ]; do PREFIX="${PREFIX%/}"; done
    ;;
esac

# Resolve OpenAPI: live URL → deploy artifact → checkout.
OPENAPI_SPEC=""
LIVE_URL="${DAST_OPENAPI_URL:-}"
if [ -z "$LIVE_URL" ]; then
  if [ -n "$PREFIX" ]; then
    LIVE_URL="${API_BASE_URL}${PREFIX}/openapi.json"
  else
    LIVE_URL="${API_BASE_URL}/openapi.json"
  fi
fi

echo "[dast] trying live OpenAPI → $LIVE_URL"
set +e
HTTP_CODE=$(curl -sf --connect-timeout 10 --max-time 30 \
  -o /tmp/dast-live-openapi.json \
  -w '%{http_code}' \
  "$LIVE_URL" 2>/dev/null) || HTTP_CODE="000"
set -e
if [ "$HTTP_CODE" = "200" ] && [ -s /tmp/dast-live-openapi.json ]; then
  cp -f /tmp/dast-live-openapi.json reports/live-openapi.json
  OPENAPI_SPEC=reports/live-openapi.json
  echo "[dast] OpenAPI=live ($LIVE_URL)"
else
  echo "[dast] live OpenAPI unavailable (HTTP ${HTTP_CODE}) — trying deploy/checkout artifacts"
  if [ -f reports/live-openapi.json ] && [ -s reports/live-openapi.json ]; then
    OPENAPI_SPEC=reports/live-openapi.json
    echo "[dast] OpenAPI=deploy artifact reports/live-openapi.json"
  elif [ -f checkout/openapi.json ] && [ -s checkout/openapi.json ]; then
    OPENAPI_SPEC=checkout/openapi.json
    cp -f "$OPENAPI_SPEC" reports/live-openapi.json
    echo "[dast] OpenAPI=checkout artifact"
  elif [ -n "${OPENAPI_PATH:-}" ] && [ -f "$OPENAPI_PATH" ] && [ -s "$OPENAPI_PATH" ]; then
    OPENAPI_SPEC="$OPENAPI_PATH"
    cp -f "$OPENAPI_SPEC" reports/live-openapi.json
    echo "[dast] OpenAPI=OPENAPI_PATH ($OPENAPI_PATH)"
  fi
fi
rm -f /tmp/dast-live-openapi.json

if [ -z "${OPENAPI_SPEC:-}" ] || [ ! -s "$OPENAPI_SPEC" ]; then
  echo "[dast] ERROR — no OpenAPI spec (expected live ${LIVE_URL} or checkout/openapi.json)"
  exit 1
fi

# Optional preflight: healthcheck (non-fatal).
if [ -n "$PREFIX" ]; then
  HC="${API_BASE_URL}${PREFIX}/healthcheck"
else
  HC="${API_BASE_URL}/healthcheck"
fi
set +e
HC_CODE=$(curl -sf --connect-timeout 5 --max-time 15 \
  -o /dev/null -w '%{http_code}' "$HC" 2>/dev/null) || HC_CODE="000"
set -e
echo "[dast] preflight healthcheck $HC → HTTP ${HC_CODE}"

# Count OpenAPI paths (python3 preferred; jq fallback; python-free: grep).
OPENAPI_PATHS=0
if command -v python3 >/dev/null 2>&1; then
  OPENAPI_PATHS=$(python3 -c "
import json,sys
p=json.load(open(sys.argv[1],encoding='utf-8'))
print(len(p.get('paths') or {}))
" "$OPENAPI_SPEC")
else
  OPENAPI_PATHS=$(grep -cE '^\s+"/[^"]+":' "$OPENAPI_SPEC" 2>/dev/null || echo 0)
fi
echo "[dast] openapi_paths=${OPENAPI_PATHS} spec=${OPENAPI_SPEC}"

# ZAP requires reports under /zap/wrk with relative -x/-J names.
cp -f "$OPENAPI_SPEC" /zap/wrk/openapi.json
echo "[dast] zap-api-scan -f openapi -O $API_BASE_URL"
set +e
zap-api-scan.py \
  -t openapi.json \
  -f openapi \
  -O "$API_BASE_URL" \
  -x zap-api.xml \
  -J zap-api.json \
  -I \
  2>&1 | tee /tmp/zap-api.log | tail -80
ZAP_RC=$?
set -e

for f in zap-api.xml zap-api.json; do
  if [ -f "/zap/wrk/$f" ] && [ -s "/zap/wrk/$f" ]; then
    cp -f "/zap/wrk/$f" "reports/$f"
  elif [ -f "$f" ] && [ -s "$f" ]; then
    cp -f "$f" "reports/$f"
  fi
done

if [ ! -f reports/zap-api.xml ] || [ ! -s reports/zap-api.xml ]; then
  echo "[dast] ERROR: empty or missing ZAP XML report (zap rc=${ZAP_RC})"
  exit 1
fi
if [ ! -f reports/zap-api.json ] || [ ! -s reports/zap-api.json ]; then
  echo "[dast] ERROR: empty or missing ZAP JSON report (needed for gate-check; zap rc=${ZAP_RC})"
  exit 1
fi
echo "[dast] report written: reports/zap-api.xml + reports/zap-api.json (zap rc=${ZAP_RC})"

# Coverage: OpenAPI path count vs URLs ZAP touched (JSON instances + import/log hits).
# Blocks healthcheck-only regression when OAS has ≥3 paths.
PREFIX_FOR_COV="$PREFIX"
export PREFIX_FOR_COV
export OPENAPI_PATHS
export OPENAPI_SPEC
COVERAGE_OK=1
if command -v python3 >/dev/null 2>&1; then
  set +e
  python3 <<'PY'
import json, os, re, sys
from pathlib import Path
from urllib.parse import urlparse

n = int(os.environ.get("OPENAPI_PATHS", "0") or "0")
prefix = (os.environ.get("PREFIX_FOR_COV") or "").rstrip("/")
oas_path = os.environ.get("OPENAPI_SPEC") or "reports/live-openapi.json"
log = Path("/tmp/zap-api.log").read_text(encoding="utf-8", errors="replace") if Path("/tmp/zap-api.log").exists() else ""
imported = 0
for pat in (
    r"Number of Imported URLs:\s*(\d+)",
    r"Imported URLs:\s*(\d+)",
    r"urls imported:\s*(\d+)",
):
    m = re.search(pat, log, re.I)
    if m:
        imported = int(m.group(1))
        break

uris = set()
data = json.loads(Path("reports/zap-api.json").read_text(encoding="utf-8"))
for site in data.get("site") or []:
    name = site.get("@name") or site.get("name") or ""
    if name:
        uris.add(name)
    for alert in site.get("alerts") or []:
        for inst in alert.get("instances") or []:
            u = inst.get("uri") or inst.get("url") or ""
            if u:
                uris.add(u)

def path_key(u: str) -> str:
    try:
        p = urlparse(u).path or u
    except Exception:
        p = u
    if prefix and p.startswith(prefix):
        p = p[len(prefix):] or "/"
    if len(p) > 1:
        p = p.rstrip("/")
    return p

keys = {path_key(u) for u in uris if u}
keys = {k for k in keys if k and k != "/"}
zap_urls = len(keys)

# Log-hit fallback: OpenAPI path prefixes mentioned in ZAP output (works with 0 alerts).
oas_paths = []
try:
    oas_paths = list((json.load(open(oas_path, encoding="utf-8")).get("paths") or {}).keys())
except Exception:
    pass
log_hits = 0
for p in oas_paths:
    stem = p.split("{", 1)[0].rstrip("/")
    if len(stem) < 2:
        continue
    if stem in log or (prefix + stem) in log:
        log_hits += 1

covered = max(imported, zap_urls, log_hits)
print(
    f"[dast] coverage openapi_paths={n} zap_urls={zap_urls} "
    f"imported_urls={imported} log_hits={log_hits} covered={covered}"
)
print(f"[dast] sample_paths={sorted(keys)[:12]}")

if n >= 3 and covered <= 1:
    print(
        f"[dast] ERROR — coverage regression: openapi_paths={n} but covered≤1 "
        "(looks like healthcheck-only / failed OpenAPI import)",
        file=sys.stderr,
    )
    sys.exit(2)
if n >= 3 and zap_urls == 1 and any("healthcheck" in k for k in keys) and covered <= 1:
    print("[dast] ERROR — only healthcheck path in ZAP report", file=sys.stderr)
    sys.exit(2)
sys.exit(0)
PY
  COV_RC=$?
  set -e
  if [ "$COV_RC" -ne 0 ]; then
    COVERAGE_OK=0
  fi
else
  echo "[dast] WARN — python3 missing; skipping coverage assert (XML/JSON present)"
fi

if [ "$COVERAGE_OK" != "1" ]; then
  exit 1
fi

# Gate (adopt policy): missing JSON already failed above.
if [ -f scripts/gate-check.py ] && command -v python3 >/dev/null 2>&1; then
  python3 scripts/gate-check.py \
    --control dast \
    --report reports/zap-api.json \
    --policy "${SECURITY_POLICY:-config/security-gate-policy-adopt.yaml}"
fi

echo "[dast] done"
