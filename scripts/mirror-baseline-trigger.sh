#!/usr/bin/env bash
# Thin wrapper → mirror-fleet-trigger.py (keeps runbook / muscle memory).
#   GITLAB_PAT=… MIRROR_PROJECT_ID=1962 bash scripts/mirror-baseline-trigger.sh [--dry-run]
# Prefer: make mirror-fleet-dry / make mirror-fleet
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) ARGS+=(--dry-run); shift ;;
    --ref) ARGS+=(--ref "$2"); shift 2 ;;
    -h|--help)
      echo "Usage: mirror-baseline-trigger.sh [--dry-run] [--ref master]"
      echo "Wraps: python3 scripts/mirror-fleet-trigger.py (enabled-only, all non-skip tiers)"
      exit 0
      ;;
    *) echo "Unknown: $1"; exit 1 ;;
  esac
done

exec python3 "$ROOT/scripts/mirror-fleet-trigger.py" --enabled-only "${ARGS[@]}"
