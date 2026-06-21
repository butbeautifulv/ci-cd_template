#!/usr/bin/env bash
# Validate GitLab OSS full profile and pin policy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
report() {
  echo "VIOLATION: $1"
  fail=1
}

PROFILE="templates/profiles/oss-full.gitlab-ci.yml"

required=(
  "$PROFILE"
  templates/gitlab/jobs/oss/versions.yml
  templates/gitlab/jobs/oss/_docker.yml
  templates/gitlab/jobs/oss/_base-validate.yml
  templates/gitlab/jobs/oss/build-push.yml
  templates/gitlab/jobs/oss/gitleaks.yml
  templates/gitlab/jobs/oss/semgrep-sast.yml
  templates/gitlab/jobs/oss/trivy-osa.yml
  templates/gitlab/jobs/oss/trivy-sca.yml
  templates/gitlab/jobs/oss/checkov-iac.yml
  templates/gitlab/jobs/oss/helm-deploy.yml
  templates/gitlab/jobs/oss/sbom-upload.yml
  templates/gitlab/jobs/registry/variables.yml
  templates/gitlab/jobs/registry/login.yml
  templates/gitlab/jobs/forbidden-files.yml
  templates/gitlab/jobs/dast.yml
  templates/gitlab/jobs/api-fuzz-schemathesis.yml
  templates/gitlab/jobs/binary-fuzz.yml
  templates/gitlab/jobs/iast-preprod.yml
  templates/gitlab/jobs/sec-func-tests.yml
  templates/gitlab/jobs/conftest-admission.yml
  templates/gitlab/jobs/nightly-full-sast.yml
  scripts/run-binary-fuzz.sh
  scripts/binary-fuzz-to-junit.py
)

for f in "${required[@]}"; do
  [[ -f "$f" ]] || report "missing: $f"
done

if grep -vE '^\s*#' "$PROFILE" | grep -qE 'Security/.*\.gitlab-ci\.yml|codeql-action|CodeQL' 2>/dev/null; then
  report "oss-full.gitlab-ci.yml must not use GitLab Security templates or CodeQL"
fi

for inc in oss/versions.yml oss/_docker.yml oss/_base-validate.yml oss/build-push.yml \
  oss/gitleaks.yml forbidden-files.yml oss/semgrep-sast.yml oss/trivy-osa.yml \
  oss/checkov-iac.yml dast.yml api-fuzz-schemathesis.yml binary-fuzz.yml \
  iast-preprod.yml oss/helm-deploy.yml conftest-admission.yml; do
  if ! grep -q "$inc" "$PROFILE"; then
    report "oss-full.gitlab-ci.yml must include jobs/$inc"
  fi
done

if grep -qE ':latest|:stable' templates/gitlab/jobs/oss/*.yml 2>/dev/null; then
  grep -nE ':latest|:stable' templates/gitlab/jobs/oss/*.yml | while read -r line; do
    report "rolling pin in oss jobs: $line"
  done
fi

ADOPT_TEST="/tmp/gitlab-oss-adopt-test-$$"
mkdir -p "$ADOPT_TEST"
if ! bash "$ROOT/scripts/adopt.sh" --profile oss-full --platform gitlab --target "$ADOPT_TEST" --dry-run >/dev/null 2>&1; then
  report "adopt.sh --profile oss-full --platform gitlab --dry-run failed"
fi
rm -rf "$ADOPT_TEST"

if [[ $fail -ne 0 ]]; then
  echo ""
  echo "GitLab OSS validation failed. See docs/platforms/gitlab-oss-full.md"
  exit 1
fi

echo "OK: GitLab OSS profile valid"
