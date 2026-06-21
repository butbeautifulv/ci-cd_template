#!/usr/bin/env bash
# Fail if OSS pipeline jobs use rolling tags or unpinned install paths.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCAN_DIRS=(
  templates/gitlab/jobs/oss
  templates/gitlab/jobs/sbom.yml
  templates/gitlab/jobs/dockerfile-lint.yml
  templates/gitlab/jobs/conftest-admission.yml
  templates/gitlab/jobs/dast.yml
  templates/gitlab/jobs/iast-preprod.yml
  templates/gitlab/jobs/api-fuzz-schemathesis.yml
  templates/gitlab/jobs/binary-fuzz.yml
  templates/gitlab/jobs/forbidden-files.yml
  templates/gitlab/jobs/sign.yml
  templates/gitlab/jobs/linter-security.yml
  templates/gitlab/jobs/nightly-full-sast.yml
  templates/gitlab/jobs/sec-func-tests.yml
  templates/gitlab/jobs/_base.yml
  templates/profiles/oss-full.gitlab-ci.yml
  templates/github/workflows/jobs/oss
  templates/github/workflows/oss
  templates/profiles/oss-full.github.yml
  config/github-oss-env.yml
)

fail=0
report() {
  echo "VIOLATION: $1"
  fail=1
}

check_path() {
  local target="$1"
  [[ -e "$target" ]] || return 0

  if grep -qE ':latest|:stable|latest-debian' "$target" 2>/dev/null; then
    grep -nE ':latest|:stable|latest-debian' "$target" | while read -r line; do
      report "$target — rolling image tag: $line"
    done
  fi

  if grep -qE 'gitleaks/releases/download|gitleaks_.*_linux_x64\.tar\.gz' "$target" 2>/dev/null; then
    grep -nE 'gitleaks/releases/download|gitleaks_.*_linux_x64\.tar\.gz' "$target" | while read -r line; do
      report "$target — Gitleaks tarball curl forbidden (use OSS_GITLEAKS_IMAGE docker): $line"
    done
  fi

  if grep -qE 'trivy/releases/download|trivy_.*_Linux-64bit\.tar\.gz' "$target" 2>/dev/null; then
    grep -nE 'trivy/releases/download|trivy_.*_Linux-64bit\.tar\.gz' "$target" | while read -r line; do
      report "$target — Trivy tarball curl forbidden (use OSS_TRIVY_IMAGE docker): $line"
    done
  fi

  if grep -qE 'install\.sh.*main|raw\.githubusercontent\.com/aquasecurity/trivy/main' "$target" 2>/dev/null; then
    grep -nE 'install\.sh.*main|raw\.githubusercontent\.com/aquasecurity/trivy/main' "$target" | while read -r line; do
      report "$target — Trivy install from main: $line"
    done
  fi

  if grep -qE 'pip install -q checkov[^=]|pip install -q ruff[^=]|pip install checkov[^=]|pip install ruff[^=]' "$target" 2>/dev/null; then
    grep -nE 'pip install -q checkov[^=]|pip install -q ruff[^=]|pip install checkov[^=]|pip install ruff[^=]' "$target" | while read -r line; do
      report "$target — unpinned pip install: $line"
    done
  fi
}

for path in "${SCAN_DIRS[@]}"; do
  check_path "$path"
done

if [[ $fail -ne 0 ]]; then
  echo ""
  echo "OSS pin validation failed. See docs/runbooks/oss-tool-pinning.md"
  exit 1
fi

echo "OK: OSS tool pins valid"
