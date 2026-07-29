#!/usr/bin/env sh
# Discover OpenAPI under SCAN_ROOT; export OPENAPI_SPEC path or empty.
# Prefers OPENAPI_PATH (CI/YAML), then common filenames.
set -eu

SCAN_ROOT="${SCAN_ROOT:-checkout}"
FOUND=""

if [ -n "${OPENAPI_PATH:-}" ]; then
  for cand in "$OPENAPI_PATH" "$SCAN_ROOT/$OPENAPI_PATH"; do
    if [ -f "$cand" ]; then
      FOUND="$cand"
      break
    fi
  done
fi

if [ -z "$FOUND" ] && [ -d "$SCAN_ROOT" ]; then
  for name in openapi.yaml openapi.yml openapi.json swagger.yaml swagger.yml swagger.json; do
    if [ -f "$SCAN_ROOT/$name" ]; then
      FOUND="$SCAN_ROOT/$name"
      break
    fi
  done
  if [ -z "$FOUND" ]; then
    FOUND=$(find "$SCAN_ROOT" \( -name 'openapi.yaml' -o -name 'openapi.yml' -o -name 'openapi.json' \
      -o -name 'swagger.yaml' -o -name 'swagger.yml' -o -name 'swagger.json' \) -type f 2>/dev/null | head -1 || true)
  fi
fi

# Fallback: discover by content marker even if filename is non-standard.
# Keeps fuzzing unblocked when services store specs as `spec.yaml`, etc.
if [ -z "$FOUND" ] && [ -d "$SCAN_ROOT" ]; then
  FOUND=$(find "$SCAN_ROOT" -type f \
    \( -name '*.yaml' -o -name '*.yml' -o -name '*.json' \) \
    -maxdepth 8 2>/dev/null \
    | while read -r f; do
        if grep -qE '(^[[:space:]]*openapi[[:space:]]*:)|(\"openapi\"[[:space:]]*:)' "$f" 2>/dev/null; then
          printf '%s\n' "$f"
          break
        fi
      done | head -n 1 || true)
fi

if [ -n "$FOUND" ]; then
  echo "[fuzz] OpenAPI=$FOUND"
  export OPENAPI_SPEC="$FOUND"
else
  echo "[fuzz] skip — no OpenAPI under $SCAN_ROOT (set openapi_path in mirror-services.yaml)"
  export OPENAPI_SPEC=""
fi
