#!/usr/bin/env sh
# Run Schemathesis against discovered OpenAPI + API_BASE_URL.
# Fail-hard: no soft skip on missing OpenAPI / API_BASE_URL / BUILD_FALLBACK /
# missing junit (tool crash). Findings policy still via gate-check.
set -eu

mkdir -p reports

# Resolve service / optional YAML fields
if [ -f scripts/resolve-mirror-service.sh ]; then
  # shellcheck disable=SC1091
  . scripts/resolve-mirror-service.sh || true
fi

# shellcheck disable=SC1091
. scripts/discover-openapi.sh

if [ "${BUILD_FALLBACK:-0}" = "1" ]; then
  echo "[fuzz] ERROR — BUILD_FALLBACK=1. Failing instead of skipping to avoid fake-green pipelines."
  exit 1
fi

if [ "${DEPLOY_SKIPPED:-0}" = "1" ]; then
  echo "[fuzz] ERROR — DEPLOY_SKIPPED=1. Failing instead of skipping to avoid fake-green pipelines."
  exit 1
fi

if [ -z "${API_BASE_URL:-}" ]; then
  echo "[fuzz] ERROR — API_BASE_URL unset (deploy-test did not set it)."
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

# Prefer live OpenAPI from the deployed app (paths include mount prefix).
# Repo checkout/openapi.json often has relative /v1/... which double-prefixes.
LIVE_USED=0
if [ -n "${API_BASE_URL:-}" ]; then
  LIVE_URL="${API_BASE_URL}${PREFIX}/openapi.json"
  echo "[fuzz] trying live OpenAPI → $LIVE_URL"
  set +e
  HTTP_CODE=$(curl -sf --connect-timeout 10 --max-time 30 \
    -o reports/live-openapi.json \
    -w '%{http_code}' \
    "$LIVE_URL" 2>/dev/null) || HTTP_CODE="000"
  set -e
  if [ "$HTTP_CODE" = "200" ] && [ -s reports/live-openapi.json ]; then
    OPENAPI_SPEC=reports/live-openapi.json
    LIVE_USED=1
    echo "[fuzz] OpenAPI=live ($LIVE_URL)"
  else
    echo "[fuzz] live OpenAPI unavailable (HTTP ${HTTP_CODE}) — fallback to checkout/registry"
    rm -f reports/live-openapi.json
  fi
fi

if [ -z "${OPENAPI_SPEC:-}" ]; then
  echo "[fuzz] ERROR — no OpenAPI spec (expected live ${PREFIX}/openapi.json or checkout/openapi.json)."
  exit 1
fi

# Schemathesis reads SCHEMATHESIS_HOOKS as a *module* name. A file path
# (e.g. tests/security/schemathesis-hooks.py) or hyphenated filename crashes
# import before any tests run — then gate-check warn-mode fake-greens.
HOOKS_FILE=""
case "${SCHEMATHESIS_HOOKS:-}" in
  ""|hooks) ;;
  *.py)
    if [ -f "${SCHEMATHESIS_HOOKS}" ]; then
      HOOKS_FILE="${SCHEMATHESIS_HOOKS}"
    fi
    ;;
  *)
    if [ -f "${SCHEMATHESIS_HOOKS}" ]; then
      HOOKS_FILE="${SCHEMATHESIS_HOOKS}"
    elif [ -f "${SCHEMATHESIS_HOOKS}.py" ]; then
      HOOKS_FILE="${SCHEMATHESIS_HOOKS}.py"
    fi
    ;;
esac
if [ -z "${HOOKS_FILE}" ] && [ -f tests/security/schemathesis-hooks.py ]; then
  HOOKS_FILE=tests/security/schemathesis-hooks.py
fi
unset SCHEMATHESIS_HOOKS || true
if [ -n "${HOOKS_FILE}" ] && [ -f "${HOOKS_FILE}" ]; then
  cp "${HOOKS_FILE}" ./hooks.py
  export SCHEMATHESIS_HOOKS=hooks
  echo "[fuzz] hooks=${SCHEMATHESIS_HOOKS} (from ${HOOKS_FILE})"
else
  echo "[fuzz] hooks=none"
fi

JUNIT_PATH=reports/schemathesis-junit.xml
ST_VER="$(schemathesis --version 2>/dev/null | head -n1 || true)"
echo "[fuzz] ${ST_VER:-schemathesis unknown}"

# Live OAS paths already include prefix → base-url is host:port only.
# Checkout OAS with relative /v1/... → base-url = host:port + prefix.
if [ "$LIVE_USED" = "1" ]; then
  FUZZ_BASE_URL="$API_BASE_URL"
else
  FUZZ_BASE_URL="${API_BASE_URL}${PREFIX}"
fi
echo "[fuzz] OpenAPI=$OPENAPI_SPEC FUZZ_BASE_URL=$FUZZ_BASE_URL live=$LIVE_USED prefix=${PREFIX:-none}"

# Default check not_a_server_error alone passes on 404 — require status_code too.
ST_CHECKS="${SCHEMATHESIS_CHECKS:-not_a_server_error,status_code_conformance,content_type_conformance,response_schema_conformance}"

# v3 (corp Nexus 3.39.x): --base-url + --junit-xml + openapi-3.1 experimental
# v4+: --url + --phases + --report junit --report-junit-path
set +e
case "${ST_VER}" in
  *"version 3."*|*" 3."*)
    echo "[fuzz] schemathesis run $OPENAPI_SPEC --base-url $FUZZ_BASE_URL -c $ST_CHECKS --junit-xml $JUNIT_PATH --experimental=openapi-3.1"
    schemathesis run -w auto "${OPENAPI_SPEC}" \
      --base-url "${FUZZ_BASE_URL}" \
      -c "${ST_CHECKS}" \
      --junit-xml "${JUNIT_PATH}" \
      --experimental=openapi-3.1 \
      --hypothesis-max-examples "${SCHEMATHESIS_MAX_EXAMPLES:-50}" \
      > /tmp/schemathesis.log 2>&1
    ;;
  *)
    SCHEMATHESIS_PHASES="${SCHEMATHESIS_PHASES:-examples,coverage,fuzzing}"
    echo "[fuzz] schemathesis run $OPENAPI_SPEC --url $FUZZ_BASE_URL phases=$SCHEMATHESIS_PHASES -c $ST_CHECKS"
    schemathesis run -w auto "${OPENAPI_SPEC}" --url "${FUZZ_BASE_URL}" \
      --phases "${SCHEMATHESIS_PHASES}" \
      -c "${ST_CHECKS}" \
      --report junit --report-junit-path "${JUNIT_PATH}" \
      > /tmp/schemathesis.log 2>&1
    ;;
esac
SC_EXIT=$?
set -e
if [ -f /tmp/schemathesis.log ]; then
  tail -n 80 /tmp/schemathesis.log
fi

# Tool never produced output → always fail (do not let adopt warn-mode mask this).
if [ ! -f "${JUNIT_PATH}" ] || [ ! -s "${JUNIT_PATH}" ]; then
  echo "[fuzz] ERROR: empty or missing junit (schemathesis rc=${SC_EXIT})"
  if [ "${SC_EXIT}" -ne 0 ]; then
    exit "${SC_EXIT}"
  fi
  exit 1
fi

echo "[fuzz] junit testcases (sample):"
grep -o 'name="[^"]*"' "${JUNIT_PATH}" | head -n 8 || true

if command -v python3 >/dev/null 2>&1; then
  set +e
  python3 scripts/gate-check.py --control fuzzing --report "${JUNIT_PATH}" \
    --policy "${SECURITY_POLICY:-config/security-gate-policy-adopt.yaml}"
  GATE_EXIT=$?
  set -e
  exit "${GATE_EXIT}"
fi

# Corp: no apt — if python missing, rely on schemathesis exit only.
echo "[fuzz] WARN: python3 missing — skip gate-check (Nexus image should include python)"
exit "${SC_EXIT}"
