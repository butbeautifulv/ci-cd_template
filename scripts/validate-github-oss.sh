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
  templates/profiles/oss-full-node.github.yml
  templates/github/workflows/base-validate.yml
  templates/github/workflows/base-validate-node.yml
  templates/github/workflows/security-gates-oss.yml
  templates/github/workflows/oss/build-push.yml
  templates/github/workflows/oss/sca-image.yml
  templates/github/actions/gate-and-export/action.yml
  scripts/normalize-sarif.py
  templates/github/workflows/jobs/oss/gitleaks.yml
  templates/github/workflows/jobs/oss/forbidden-files.yml
  templates/github/workflows/jobs/oss/conftest-admission.yml
  templates/github/workflows/jobs/oss/sbom-upload.yml
  templates/github/workflows/jobs/oss/semgrep-sast.yml
  templates/github/workflows/jobs/oss/trivy-osa.yml
  templates/github/workflows/jobs/oss/checkov-iac.yml
  templates/github/workflows/jobs/oss/dockerfile-lint.yml
  templates/github/workflows/jobs/oss/linter-security.yml
  templates/github/workflows/jobs/sbom-oss.yml
  templates/github/workflows/jobs/sign-oss.yml
  templates/github/workflows/dast-compose-oss.yml
  config/github-oss-env.yml
)

for f in "${required[@]}"; do
  [[ -f "$f" ]] || report "missing: $f"
done

oss_scan_dir="templates/github/workflows/jobs/oss"
if ! grep -q 'base-validate.yml' templates/profiles/oss-full.github.yml; then
  report "oss-full.github.yml must use base-validate.yml"
fi

if ! grep -q 'base-validate-node.yml' templates/profiles/oss-full-node.github.yml; then
  report "oss-full-node.github.yml must use base-validate-node.yml"
fi

if ! grep -q 'forbidden-files' templates/github/workflows/security-gates-oss.yml; then
  report "security-gates-oss.yml must include forbidden-files job"
fi

if grep -qE '\./\.github/workflows/jobs/' templates/github/workflows/security-gates-oss.yml; then
  report "security-gates-oss.yml must use inline jobs (no nested ./.github/workflows/jobs/ refs)"
fi

if grep -qE '(if:.*vars\.|env:.*vars\.|if:.*secrets\.|env:.*secrets\.)' \
  templates/github/actions/gate-and-export/action.yml 2>/dev/null; then
  report "gate-and-export composite uses vars/secrets in if/env — pass via inputs from caller workflow"
fi

if ! grep -q 'normalize-sarif.py' templates/github/actions/gate-and-export/action.yml; then
  report "gate-and-export must call normalize-sarif.py"
fi

if ! grep -q 'defectdojo_url' templates/github/actions/gate-and-export/action.yml; then
  report "gate-and-export must accept defectdojo_url input"
fi

for job in "$oss_scan_dir"/gitleaks.yml "$oss_scan_dir"/semgrep-sast.yml \
  "$oss_scan_dir"/trivy-osa.yml "$oss_scan_dir"/checkov-iac.yml \
  "$oss_scan_dir"/dockerfile-lint.yml "$oss_scan_dir"/linter-security.yml \
  "$oss_scan_dir"/forbidden-files.yml; do
  if ! grep -q 'gate-and-export' "$job"; then
    report "OSS scan job must use gate-and-export composite: $job"
  fi
done

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

if ! grep -q 'security-gates-oss.yml' templates/profiles/oss-full-node.github.yml; then
  report "oss-full-node.github.yml must use security-gates-oss.yml"
fi

for wf in security-gates-oss.yml oss/build-push.yml oss/sca-image.yml; do
  path="templates/github/workflows/$wf"
  while read -r ref; do
    target="${ref#./.github/workflows/}"
    [[ -f "templates/github/workflows/$target" ]] || report "missing workflow ref in $path: $target"
  done < <(grep -oE '\./\.github/workflows/[^"]+\.yml' "$path" 2>/dev/null | sort -u || true)
done

for profile in templates/profiles/*.github.yml; do
  hit="$(awk '
    /^[[:space:]]*with:[[:space:]]*$/ { in_with=1; next }
    in_with && /^[[:space:]]{2}[a-zA-Z0-9_-]+:/ && !/^[[:space:]]{4,}/ { in_with=0 }
    in_with && /\$\{\{[[:space:]]*env\./ { print FILENAME ":" NR ":" $0; exit }
  ' "$profile" 2>/dev/null || true)"
  [[ -z "$hit" ]] || report "env context in with: block — $hit"
done

for profile in oss-full oss-full-node; do
  ADOPT_TEST="/tmp/oss-adopt-test-${profile}-$$"
  mkdir -p "$ADOPT_TEST"
  if ! bash "$ROOT/scripts/adopt.sh" --profile "$profile" --platform github --target "$ADOPT_TEST" --dry-run >/dev/null 2>&1; then
    report "adopt.sh --profile $profile --platform github --dry-run failed"
  fi
  rm -rf "$ADOPT_TEST"
done

if [[ $fail -ne 0 ]]; then
  echo ""
  echo "GitHub OSS validation failed. See docs/platforms/github-oss-full.md"
  exit 1
fi

echo "OK: GitHub OSS profile valid"
