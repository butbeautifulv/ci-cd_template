#!/usr/bin/env bash
# Adopt DevSecOps template phases into a target repository
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: adopt.sh --profile PROFILE --platform PLATFORM --target DIR [--dry-run]

Profiles: minimal | shift-left | supply-chain | full
Platforms: gitlab | github

Examples:
  ./scripts/adopt.sh --profile shift-left --platform gitlab --target ~/myapp
  ./scripts/adopt.sh --profile full --platform github --target ~/myapp --dry-run
EOF
  exit 1
}

PROFILE=""
PLATFORM=""
TARGET=""
DRY_RUN=0
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="$2"; shift 2 ;;
    --platform) PLATFORM="$2"; shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown: $1"; usage ;;
  esac
done

[[ -n "$PROFILE" && -n "$PLATFORM" && -n "$TARGET" ]] || usage
[[ -d "$TARGET" ]] || { echo "Target not found: $TARGET"; exit 1; }

copy() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "COPY $src -> $dest"
  else
    cp -r "$src" "$dest"
    echo "Copied $dest"
  fi
}

echo "=== DevSecOps adopt: profile=$PROFILE platform=$PLATFORM ==="

# Policy always
copy "$ROOT/config/security-gate-policy.yaml" "$TARGET/config/security-gate-policy.yaml"
copy "$ROOT/scripts/gate-check.py" "$TARGET/scripts/gate-check.py"
chmod +x "$TARGET/scripts/gate-check.py" 2>/dev/null || true

if [[ "$PLATFORM" == "gitlab" ]]; then
  copy "$ROOT/templates/profiles/${PROFILE}.gitlab-ci.yml" "$TARGET/.gitlab-ci.yml"
  copy "$ROOT/templates/gitlab/jobs" "$TARGET/.gitlab/jobs"
  copy "$ROOT/templates/CODEOWNERS" "$TARGET/CODEOWNERS"
elif [[ "$PLATFORM" == "github" ]]; then
  copy "$ROOT/templates/github/workflows" "$TARGET/.github/workflows"
  copy "$ROOT/templates/profiles/${PROFILE}.github.yml" "$TARGET/.github/workflows/ci-profile.yml"
  copy "$ROOT/templates/github/dependabot.yml" "$TARGET/.github/dependabot.yml"
  copy "$ROOT/templates/CODEOWNERS" "$TARGET/CODEOWNERS"
else
  echo "Unknown platform: $PLATFORM"; exit 1
fi

case "$PROFILE" in
  minimal)    PHASES="A2" ;;
  shift-left) PHASES="A2 B1-B6" ;;
  supply-chain) PHASES="A2 B1-B6 C1-C4" ;;
  full)       PHASES="A2 B1-B6 C1-C4 D1-D3 F1-F3" ;;
  *) echo "Unknown profile: $PROFILE"; exit 1 ;;
esac

cat <<EOF

=== Checklist ===
[ ] Fix include paths in .gitlab-ci.yml (local: '.gitlab/jobs/...')
[ ] Enable branch protection — docs/platforms/${PLATFORM}.md
[ ] Set REGISTRY / ghcr.io secrets
[ ] Phases included: $PHASES
[ ] Run: python3 scripts/gate-check.py --help
[ ] See docs/adoption-checklist.md

EOF
