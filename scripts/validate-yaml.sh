#!/usr/bin/env bash
# Validate YAML syntax in templates/ (requires yamllint or python)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
if command -v yamllint >/dev/null 2>&1; then
  yamllint -d relaxed templates/ .github/workflows/ 2>/dev/null || yamllint templates/
else
  echo "yamllint not found — using python yaml parse"
  python3 <<'PY'
import sys
from pathlib import Path
try:
    import yaml
except ImportError:
    print("Install pyyaml or yamllint for YAML validation", file=sys.stderr)
    sys.exit(0)
errors = 0
for p in Path("templates").rglob("*.yml"):
    try:
        list(yaml.safe_load_all(p.read_text()))
    except Exception as e:
        print(f"FAIL {p}: {e}")
        errors += 1
for p in Path("templates").rglob("*.yaml"):
    try:
        list(yaml.safe_load_all(p.read_text()))
    except Exception as e:
        print(f"FAIL {p}: {e}")
        errors += 1
sys.exit(1 if errors else 0)
PY
  fail=$?
fi

python3 scripts/validate-policy.py || fail=1
exit $fail
