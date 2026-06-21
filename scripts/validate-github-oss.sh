#!/usr/bin/env bash
# Validate GitHub OSS full profile workflows and pin policy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
report() {
  echo "VIOLATION: $1"
  fail=1
}

required=(
  templates/profiles/oss-full.github.yml
  templates/github/workflows/security-gates-oss.yml
  templates/github/workflows/oss/build-push.yml
  templates/github/workflows/oss/sca-image.yml
  templates/github/workflows/jobs/oss/gitleaks.yml
  templates/github/workflows/jobs/oss/semgrep-sast.yml
  templates/github/workflows/jobs/oss/trivy-osa.yml
  templates/github/workflows/jobs/oss/checkov-iac.yml
  templates/github/workflows/jobs/oss/dockerfile-lint.yml
  templates/github/workflows/jobs/oss/linter-security.yml
  templates/github/workflows/jobs/sbom-oss.yml
  templates/github/workflows/jobs/sign-oss.yml
  config/github-oss-env.yml
)

for f in "${required[@]}"; do
  [[ -f "$f" ]] || report "missing: $f"
done

oss_scan_dir="templates/github/workflows/jobs/oss"
if grep -qE 'trivy-action@0\.28|semgrep-action@v1|:latest|:stable' "$oss_scan_dir"/*.yml 2>/dev/null; then
  grep -nE 'trivy-action@0\.28|semgrep-action@v1|:latest|:stable' "$oss_scan_dir"/*.yml | while read -r line; do
    report "rolling pin in oss jobs: $line"
  done
fi

if grep -qE 'codeql-action|dependency-review-action' templates/profiles/oss-full.github.yml 2>/dev/null; then
  report "oss-full.github.yml must not reference CodeQL or dependency-review actions"
fi

if ! grep -q 'security-gates-oss.yml' templates/profiles/oss-full.github.yml; then
  report "oss-full.github.yml must use security-gates-oss.yml"
fi

for wf in security-gates-oss.yml oss/build-push.yml oss/sca-image.yml; do
  path="templates/github/workflows/$wf"
  while read -r ref; do
    target="${ref#./.github/workflows/}"
    [[ -f "templates/github/workflows/$target" ]] || report "missing workflow ref in $path: $target"
  done < <(grep -oE '\./\.github/workflows/[^"]+\.yml' "$path" 2>/dev/null | sort -u || true)
done

ADOPT_TEST="/tmp/oss-adopt-test-$$"
mkdir -p "$ADOPT_TEST"
if ! bash "$ROOT/scripts/adopt.sh" --profile oss-full --platform github --target "$ADOPT_TEST" --dry-run >/dev/null 2>&1; then
  report "adopt.sh --profile oss-full --platform github --dry-run failed"
fi
rm -rf "$ADOPT_TEST"

if [[ $fail -ne 0 ]]; then
  echo ""
  echo "GitHub OSS validation failed. See docs/platforms/github-oss-full.md"
  exit 1
fi

echo "OK: GitHub OSS profile valid"
