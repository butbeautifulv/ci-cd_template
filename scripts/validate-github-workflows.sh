#!/usr/bin/env bash
# Validate GitHub workflow templates: actionlint-style rules for reusable workflow calls.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
report() {
  echo "VIOLATION: $1"
  fail=1
}

check_env_in_with() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  local hit
  hit="$(awk '
    /^[[:space:]]*with:[[:space:]]*$/ { in_with=1; next }
    in_with && /^[[:space:]]{2}[a-zA-Z0-9_-]+:/ && !/^[[:space:]]{4,}/ { in_with=0 }
    in_with && /\$\{\{[[:space:]]*env\./ {
      print FILENAME ":" NR ":" $0
      found=1
      exit
    }
    END { exit(found ? 0 : 1) }
  ' "$file" 2>/dev/null || true)"
  if [[ -n "$hit" ]]; then
    report "env context in with: block — $hit"
  fi
}

check_secrets_inherit() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  python3 - "$file" <<'PY' || report "secrets: inherit missing on reusable uses: in $file"
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
blocks = re.split(r"\n(?=  [a-zA-Z0-9_-]+:)", "\n" + text)
for block in blocks:
    if "uses: ./.github/workflows/" not in block:
        continue
    if "secrets: inherit" not in block:
        job = re.search(r"^  ([a-zA-Z0-9_-]+):", block)
        name = job.group(1) if job else "?"
        print(f"missing secrets: inherit on job {name}", file=sys.stderr)
        sys.exit(1)
PY
}

for profile in templates/profiles/*.github.yml; do
  check_env_in_with "$profile"
  check_secrets_inherit "$profile"
done

for wf in templates/github/workflows/ci.yml templates/github/workflows/security-shift-left.yml; do
  check_env_in_with "$wf"
done

if [[ ! -f config/security-gate-policy-adopt.yaml ]]; then
  report "missing config/security-gate-policy-adopt.yaml (required by shift-left profiles)"
fi

for ref in templates/profiles/shift-left.github.yml templates/github/workflows/security-shift-left.yml; do
  if grep -q 'security-gate-policy-adopt.yaml' "$ref" 2>/dev/null; then
    [[ -f config/security-gate-policy-adopt.yaml ]] || report "$ref references adopt policy but file missing"
  fi
done

if ! grep -q 'sast_job:' templates/github/workflows/security-gates.yml; then
  report "security-gates.yml must expose sast_job input"
fi

ADOPT_TEST="/tmp/shift-left-adopt-test-$$"
mkdir -p "$ADOPT_TEST"
touch "$ADOPT_TEST/uv.lock"
  if ! bash "$ROOT/scripts/adopt.sh" --profile shift-left --platform github --target "$ADOPT_TEST" >/dev/null 2>&1; then
    report "adopt.sh shift-left github failed"
  else
    [[ -f "$ADOPT_TEST/config/security-gate-policy-adopt.yaml" ]] || \
      report "adopt must copy security-gate-policy-adopt.yaml for shift-left"
    if ! grep -q 'sast_job: sast-python' "$ADOPT_TEST/.github/workflows/ci-profile.yml" 2>/dev/null; then
      report "uv.lock target should get sast-python in ci-profile.yml"
    fi
    for f in "$ADOPT_TEST/.github/workflows/ci-profile.yml" "$ADOPT_TEST/.github/workflows/security-shift-left.yml"; do
      check_env_in_with "$f"
    done
  fi
rm -rf "$ADOPT_TEST"

if [[ $fail -ne 0 ]]; then
  echo ""
  echo "GitHub workflow validation failed."
  exit 1
fi

echo "OK: GitHub workflow templates valid"
