#!/usr/bin/env bash
# Adopt DevSecOps template phases into a target repository
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: adopt.sh --profile PROFILE --platform PLATFORM --target DIR [--dry-run]

Profiles: minimal | shift-left | supply-chain | full | ai-ml | oss-full
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
copy "$ROOT/config/aspm-export.yaml" "$TARGET/config/aspm-export.yaml"
copy "$ROOT/config/oss-tool-versions.yaml" "$TARGET/config/oss-tool-versions.yaml"
copy "$ROOT/config/artifact-registry.yaml" "$TARGET/config/artifact-registry.yaml"
if [[ -f "$ROOT/config/github-oss-env.yml" ]]; then
  copy "$ROOT/config/github-oss-env.yml" "$TARGET/config/github-oss-env.yml"
fi
copy "$ROOT/scripts/gate-check.py" "$TARGET/scripts/gate-check.py"
copy "$ROOT/scripts/aspm-export.py" "$TARGET/scripts/aspm-export.py"
copy "$ROOT/scripts/ai-ml-scan.py" "$TARGET/scripts/ai-ml-scan.py"
copy "$ROOT/scripts/registry-login.sh" "$TARGET/scripts/registry-login.sh"
copy "$ROOT/scripts/registry-auth-env.sh" "$TARGET/scripts/registry-auth-env.sh"
copy "$ROOT/scripts/registry-resolve-env.sh" "$TARGET/scripts/registry-resolve-env.sh"
chmod +x "$TARGET/scripts/gate-check.py" 2>/dev/null || true
chmod +x "$TARGET/scripts/aspm-export.py" 2>/dev/null || true
chmod +x "$TARGET/scripts/registry-login.sh" 2>/dev/null || true
chmod +x "$TARGET/scripts/registry-auth-env.sh" 2>/dev/null || true
chmod +x "$TARGET/scripts/registry-resolve-env.sh" 2>/dev/null || true

if [[ "$PLATFORM" == "gitlab" ]]; then
  copy "$ROOT/templates/profiles/${PROFILE}.gitlab-ci.yml" "$TARGET/.gitlab-ci.yml"
  copy "$ROOT/templates/gitlab/jobs" "$TARGET/.gitlab/jobs"
  copy "$ROOT/templates/CODEOWNERS" "$TARGET/CODEOWNERS"
  if [[ "$PROFILE" == "oss-full" ]]; then
    if [[ -d "$TARGET/chart" ]]; then
      echo "Skip chart copy — $TARGET/chart already exists"
    else
      copy "$ROOT/templates/k8s/helm/sample-app" "$TARGET/chart"
    fi
  fi
  if [[ $DRY_RUN -eq 0 ]]; then
    sed -i "s|local: '/templates/gitlab/jobs/|local: '.gitlab/jobs/|g" "$TARGET/.gitlab-ci.yml"
    sed -i 's|local: "/templates/gitlab/jobs/|local: ".gitlab/jobs/|g' "$TARGET/.gitlab-ci.yml"
    echo "Rewrote .gitlab-ci.yml include paths -> .gitlab/jobs/"
  fi
elif [[ "$PLATFORM" == "github" ]]; then
  copy "$ROOT/templates/github/workflows" "$TARGET/.github/workflows"
  copy "$ROOT/templates/profiles/${PROFILE}.github.yml" "$TARGET/.github/workflows/ci-profile.yml"
  copy "$ROOT/templates/github/dependabot.yml" "$TARGET/.github/dependabot.yml"
  copy "$ROOT/templates/CODEOWNERS" "$TARGET/CODEOWNERS"
  if [[ "$PROFILE" == "full" ]]; then
    copy "$ROOT/templates/github/workflows/nightly-sast.yml" "$TARGET/.github/workflows/nightly-sast.yml"
  fi
  if [[ "$PROFILE" == "oss-full" ]]; then
    copy "$ROOT/templates/github/workflows/nightly-sast-oss.yml" "$TARGET/.github/workflows/nightly-sast-oss.yml"
    copy "$ROOT/templates/github/workflows/dast-oss.yml" "$TARGET/.github/workflows/dast-oss.yml"
    if [[ $DRY_RUN -eq 0 ]]; then
      cp "$TARGET/.github/workflows/ci-profile.yml" "$TARGET/.github/workflows/ci.yml"
      echo "Activated oss-full as .github/workflows/ci.yml"
    fi
  fi
else
  echo "Unknown platform: $PLATFORM"; exit 1
fi

case "$PROFILE" in
  minimal)    PHASES="A2" ;;
  shift-left) PHASES="A2 B1-B6" ;;
  supply-chain) PHASES="A2 B1-B6 C1-C4" ;;
  full)       PHASES="A2 B1-B6 C1-C4 D1-D3 F1-F3" ;;
  ai-ml)      PHASES="A2 B1-B6 AI1 AI2 ML1 ML2 ML3(optional)" ;;
  oss-full)   PHASES="A2 B1-B6 C1-C4 D1 Helm deploy F3 (100% OSS scanners)" ;;
  *) echo "Unknown profile: $PROFILE"; exit 1 ;;
esac

cat <<EOF

=== Checklist ===
[ ] GitLab: include paths rewritten to .gitlab/jobs/ (if adopt ran without --dry-run)
[ ] Enable branch protection — docs/platforms/${PLATFORM}.md
[ ] Set REGISTRY / ghcr.io secrets
[ ] Phases included: $PHASES
[ ] Gates: SAST/SCA/IaC block C/H; secrets/dockerfile/linters warn (shift-left)
[ ] ai-ml profile: PII block (ml_data); AI scans warn
[ ] oss-full GitLab: set KUBECONFIG (file), enable Container Registry; chart/ copied if missing
[ ] oss-full GitHub: enable GHCR (packages: write), copy ci-profile.yml → ci.yml on adopt
[ ] ASPM: set DEFECTDOJO_URL + DEFECTDOJO_API_TOKEN for findings export
[ ] Run: python3 scripts/gate-check.py --help
[ ] Validate: bash scripts/validate-yaml.sh && bash scripts/validate-oss-pins.sh && bash scripts/validate-registry-config.sh && bash scripts/validate-github-oss.sh && python3 scripts/validate-policy.py
[ ] See docs/adoption-checklist.md

EOF
