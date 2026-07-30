#!/usr/bin/env sh
# ASPM export entry for scan-job after_script (DefectDojo upload).
# Env:
#   ASPM_CONTROL  — required (secrets|sast|osa|…)
#   ASPM_REPORT   — required path to report artifact
#   ASPM_SKIP_EMPTY — default "true"; set "false" for DAST/fuzz (create Test even if empty)
#   ASPM_CONFIG   — optional path to aspm-export.yaml
#   DEFECTDOJO_*  — aspm-export.py / DefectDojo
#   OSS_PYTHON_IMAGE — docker fallback when python3 missing (shell runners)
#
# Exit 0 on skip (missing/empty artifact). Fail when export fails and
# DEFECTDOJO_FAIL_ON_ERROR=true, or when artifact exists but no python/docker.
set -eu

CONTROL="${ASPM_CONTROL:-}"
REPORT="${ASPM_REPORT:-}"
SKIP_EMPTY="${ASPM_SKIP_EMPTY:-true}"
CONFIG="${ASPM_CONFIG:-config/aspm-export.yaml}"

if [ -z "$CONTROL" ]; then
  echo "[aspm] skip — ASPM_CONTROL unset"
  exit 0
fi
if [ -z "$REPORT" ]; then
  echo "[aspm] skip — ASPM_REPORT unset"
  exit 0
fi

if [ -f scripts/resolve-mirror-service.sh ] && { [ -n "${CI_COMMIT_TAG:-}" ] || [ -n "${SERVICE_NAME:-}" ]; }; then
  # shellcheck disable=SC1091
  . scripts/resolve-mirror-service.sh || true
fi

echo "[aspm] product=${DEFECTDOJO_PRODUCT_NAME:-unset} control=$CONTROL report=$REPORT"

if [ ! -f "$REPORT" ]; then
  echo "[aspm] skip — artifact $REPORT not found (scan failed or skipped; not an import success)"
  exit 0
fi
if [ ! -s "$REPORT" ]; then
  echo "[aspm] skip — artifact $REPORT is empty (not an import success)"
  exit 0
fi

# Empty JSON list payload (e.g. [] from some scanners) — skip when skip-empty on.
if [ "$SKIP_EMPTY" = "true" ] && command -v python3 >/dev/null 2>&1; then
  if python3 -c "import json,sys; d=json.load(open(sys.argv[1], encoding='utf-8')); raise SystemExit(0 if isinstance(d,list) and len(d)==0 else 1)" "$REPORT" 2>/dev/null; then
    echo "[aspm] skip — artifact $REPORT contains empty list payload (not an import success)"
    exit 0
  fi
fi

EXTRA=""
if [ "$SKIP_EMPTY" = "true" ]; then
  EXTRA="--skip-empty"
fi

run_aspm() {
  if command -v python3 >/dev/null 2>&1; then
    # shellcheck disable=SC2086
    python3 scripts/aspm-export.py --control "$CONTROL" --report "$REPORT" --config "$CONFIG" $EXTRA
    return $?
  fi
  if command -v docker >/dev/null 2>&1 && [ -n "${OSS_PYTHON_IMAGE:-}" ]; then
    echo "[aspm] python3 missing — docker run ${OSS_PYTHON_IMAGE}"
    # shellcheck disable=SC2086
    docker run --rm \
      -e DEFECTDOJO_URL \
      -e DEFECTDOJO_API_TOKEN \
      -e DEFECTDOJO_PRODUCT_NAME \
      -e DEFECTDOJO_ENGAGEMENT \
      -e DEFECTDOJO_FAIL_ON_ERROR \
      -e DEFECTDOJO_INSECURE \
      -e CI_PROJECT_NAME \
      -e CI_COMMIT_SHA \
      -e CI_COMMIT_REF_NAME \
      -e CI_PIPELINE_ID \
      -v "$PWD:/work" -w /work \
      "${OSS_PYTHON_IMAGE}" \
      python3 scripts/aspm-export.py --control "$CONTROL" --report "$REPORT" --config "$CONFIG" $EXTRA
    return $?
  fi
  echo "[aspm] ERROR: artifact present but python3/docker unavailable — refusing soft-green skip"
  return 1
}

if run_aspm; then
  exit 0
fi
rc=$?
if [ "${DEFECTDOJO_FAIL_ON_ERROR:-false}" = "true" ]; then
  exit "$rc"
fi
echo "[aspm] WARN: export failed (rc=$rc) but DEFECTDOJO_FAIL_ON_ERROR!=true — continuing"
exit 0
