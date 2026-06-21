#!/usr/bin/env bash
# Validate YAML syntax in templates/ (requires yamllint or python)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
if command -v yamllint >/dev/null 2>&1; then
  # GitLab CI uses !reference — yamllint cannot parse it; lint GitHub + config only
  mapfile -t yml_files < <(
    find .github/workflows templates/github/workflows templates/profiles config \
      \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null | sort
  )
  if ! yamllint -d relaxed --no-warnings "${yml_files[@]}"; then
    fail=1
  fi
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
    if "templates/gitlab" in str(p):
        continue
    try:
        list(yaml.safe_load_all(p.read_text()))
    except Exception as e:
        print(f"FAIL {p}: {e}")
        errors += 1
for p in Path("templates").rglob("*.yaml"):
    if "templates/k8s/helm" in str(p) or "templates/gitlab" in str(p):
        continue
    try:
        list(yaml.safe_load_all(p.read_text()))
    except Exception as e:
        print(f"FAIL {p}: {e}")
        errors += 1
for p in Path(".github/workflows").rglob("*.yml"):
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
bash scripts/validate-oss-pins.sh || fail=1
bash scripts/validate-pin-sync.sh || fail=1
bash scripts/validate-registry-config.sh || fail=1
bash scripts/validate-github-oss.sh || fail=1
bash scripts/validate-gitlab-oss.sh || fail=1
exit $fail
