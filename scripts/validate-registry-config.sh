#!/usr/bin/env bash
# Validate artifact registry abstraction (no hardcoded GitLab-only login in OSS jobs).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
report() {
  echo "VIOLATION: $1"
  fail=1
}

required_files=(
  config/artifact-registry.yaml
  templates/gitlab/jobs/registry/variables.yml
  templates/gitlab/jobs/registry/login.yml
  scripts/registry-login.sh
  scripts/registry-auth-env.sh
  scripts/registry-resolve-env.sh
)

for f in "${required_files[@]}"; do
  [[ -f "$f" ]] || report "missing file: $f"
done

for job in templates/gitlab/jobs/oss/build-push.yml templates/gitlab/jobs/oss/trivy-sca.yml; do
  if grep -qE 'CI_REGISTRY_PASSWORD|CI_REGISTRY_USER' "$job" 2>/dev/null; then
    grep -nE 'CI_REGISTRY_PASSWORD|CI_REGISTRY_USER' "$job" | while read -r line; do
      report "$job — hardcoded GitLab registry creds: $line"
    done
  fi
done

if ! grep -q 'registry/variables.yml' templates/profiles/oss-full.gitlab-ci.yml; then
  report "oss-full profile must include registry/variables.yml"
fi

if ! grep -q 'registry/login.yml' templates/profiles/oss-full.gitlab-ci.yml; then
  report "oss-full profile must include registry/login.yml"
fi

if ! grep -q '\.registry_login' templates/gitlab/jobs/oss/build-push.yml; then
  report "build-push.yml must extend .registry_login"
fi

if ! grep -q '\.registry_auth_env' templates/gitlab/jobs/oss/trivy-sca.yml; then
  report "trivy-sca.yml must extend .registry_auth_env"
fi

# Manifest backends present in variables doc
for backend in gitlab nexus harbor artifactory generic; do
  if ! grep -q "${backend}:" config/artifact-registry.yaml; then
    report "artifact-registry.yaml missing backend: $backend"
  fi
done

if [[ $fail -ne 0 ]]; then
  echo ""
  echo "Registry config validation failed. See docs/runbooks/nexus-docker-registry.md"
  exit 1
fi

echo "OK: artifact registry config valid"
