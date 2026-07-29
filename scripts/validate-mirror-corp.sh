#!/usr/bin/env bash
# Corp/offline invariants for oss-full-service-mirror (Nexus-only, Kaniko, no hotfix spam).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
FAIL=0

fail() { echo "FAIL: $*"; FAIL=1; }
ok() { echo "OK: $*"; }

PROFILE="templates/profiles/oss-full-service-mirror.gitlab-ci.yml"
KANIKO="templates/gitlab/jobs/oss/build-kaniko.yml"
FUZZ="templates/gitlab/jobs/oss/api-fuzz-schemathesis-mirror.yml"

[[ -f "$PROFILE" ]] || fail "missing $PROFILE"
[[ -f "$KANIKO" ]] || fail "missing $KANIKO"
[[ -f "$FUZZ" ]] || fail "missing $FUZZ"

# Mirror profile must be Nexus-literal / no public registries.
for pat in 'ghcr\.io' 'pypi\.org' 'semgrep\.dev' '(^|[^a-zA-Z0-9_-])p/ci([^a-zA-Z0-9_]|$)'; do
  if grep -nE "$pat" "$PROFILE" | grep -vE '^\s*[0-9]+:\s*#' >/dev/null 2>&1; then
    grep -nE "$pat" "$PROFILE" || true
    fail "banned '$pat' in mirror profile"
  else
    ok "profile clean of $pat"
  fi
done

RUNTIME_SCAN=(
  templates/gitlab/jobs/aspm
  templates/gitlab/jobs/linter-security.yml
  templates/gitlab/jobs/oss/bandit-sast.yml
  templates/gitlab/jobs/oss/semgrep-sast.yml
  templates/gitlab/jobs/oss/build-kaniko.yml
  templates/gitlab/jobs/oss/api-fuzz-schemathesis-mirror.yml
  templates/gitlab/jobs/oss/sync-sources.yml
)
hits=$(grep -RIn 'pypi\.org' "${RUNTIME_SCAN[@]}" 2>/dev/null | grep -vE '^\S+:\s*#|no pypi|No pypi|not.*pypi' || true)
if [[ -n "$hits" ]]; then
  echo "$hits"
  fail "pypi.org runtime reference in mirror upload/scan jobs"
else
  ok "no pypi.org in mirror runtime jobs"
fi

# Fuzz / DAST / kaniko must not apt-get
for f in "$FUZZ" scripts/run-schemathesis-mirror.sh scripts/run-dast-zap-api-mirror.sh; do
  if grep -nE 'apt-get|apk add' "$f" 2>/dev/null; then
    fail "apt/apk in $f"
  else
    ok "no apt/apk in $f"
  fi
done

# Image refs must go through $OSS_* / $NEXUS_* variables (override hosts via CI vars).
# Ban hardcoded host:port in image:/name: lines — defaults live only under variables:.
if grep -nE '^\s+(name|image):\s*.*nexus\.svo\.aero' "$PROFILE" | grep -vE '^\s*[0-9]+:\s*#' >/dev/null 2>&1; then
  grep -nE '^\s+(name|image):\s*.*nexus\.svo\.aero' "$PROFILE" || true
  fail "hardcoded nexus.svo.aero in image: lines — use \$OSS_*_IMAGE / \$NEXUS_DOCKER_*"
else
  ok "profile image: lines use variables (no hardcoded nexus host)"
fi

grep -q 'NEXUS_DOCKER_PREFIX:' "$PROFILE" || fail "profile must declare NEXUS_DOCKER_PREFIX"
grep -q 'NEXUS_DOCKER_GROUP:' "$PROFILE" || fail "profile must declare NEXUS_DOCKER_GROUP"
ok "profile declares NEXUS_DOCKER_PREFIX/GROUP"

# OSS image vars must be composed from Nexus prefixes (not public registries).
if ! grep -qE 'OSS_KANIKO_IMAGE:.*NEXUS_DOCKER_PREFIX' "$PROFILE"; then
  fail "OSS_KANIKO_IMAGE must reference \$NEXUS_DOCKER_PREFIX"
fi
ok "OSS_KANIKO_IMAGE composed from NEXUS_DOCKER_PREFIX"
grep -q 'build-kaniko.yml' "$PROFILE" || fail "profile must include build-kaniko.yml"
ok "profile includes build-kaniko"

grep -q 'kaniko-mirror-build' "$KANIKO" || fail "build must call kaniko-mirror-build.sh"
ok "kaniko-mirror-build wired"

if grep -nE 'docker:.*dind|DOCKER_HOST|mirror-build-image' "$KANIKO"; then
  fail "build-kaniko must be Kaniko-only (no dind/docker helper)"
else
  ok "Kaniko-only build job"
fi

if grep -q 'cxado-docker/kaniko-executor' "$PROFILE"; then
  ok "kaniko image pin in profile (kaniko-executor)"
elif grep -q 'cxado-docker/kaniko-mirror-helper' "$PROFILE"; then
  ok "kaniko image pin in profile (kaniko-mirror-helper)"
else
  fail "profile must use cxado-docker/kaniko-executor or cxado-docker/kaniko-mirror-helper image"
fi

grep -q 'cxado-docker/schemathesis' "$PROFILE" || fail "profile must use cxado-docker/schemathesis"
ok "schemathesis image pin in profile"

grep -q 'allow_failure: false' "$KANIKO" || fail "build must allow_failure: false"
ok "build hard-fail"

python3 - <<'PY' || fail "non-cleanup allow_failure:true in profile"
from pathlib import Path
text = Path("templates/profiles/oss-full-service-mirror.gitlab-ci.yml").read_text().splitlines()
job = None
for i, line in enumerate(text, 1):
    if line and not line.startswith(" ") and not line.startswith("#") and line.endswith(":"):
        job = line[:-1]
    if "allow_failure: true" in line and job not in ("cleanup-runner",):
        raise SystemExit(f"{job}:{i}")
print("ok")
PY
ok "profile hard-fail (only cleanup soft)"

grep -q 'BUILD_FALLBACK' scripts/kaniko-mirror-build.sh || fail "kaniko script missing BUILD_FALLBACK"
ok "BUILD_FALLBACK in kaniko script"

grep -q 'mirror-build-image.sh' scripts/point-copy-mirror.sh || fail "point-copy missing mirror-build-image.sh"
ok "point-copy lists mirror-build-image"

if grep -E '^exit 0$' scripts/resolve-mirror-service.sh; then
  fail "resolve-mirror-service.sh must not exit 0 (sourced from CI)"
else
  ok "resolve has no exit 0"
fi

grep -q 'hotfix' "$PROFILE" || fail "profile missing hotfix ban"
ok "hotfix workflow ban present"

if grep -q 'cleanup-runner.yml' "$PROFILE"; then
  fail "profile must not include cleanup-runner.yml (uses .oss_docker_job)"
else
  ok "no cleanup-runner.yml include"
fi

grep -q 'api-fuzz-schemathesis-mirror' "$PROFILE" || fail "profile missing schemathesis include"
ok "schemathesis included"

grep -q 'sync-sources.yml' "$PROFILE" || fail "profile missing sync-sources"
ok "sync-sources included"

grep -q 'GIT_CLEAN_FLAGS' "$PROFILE" || fail "mirror profile missing GIT_CLEAN_FLAGS"
ok "GIT_CLEAN_FLAGS present"

# Must not include docker build-push for mirror profile
if grep -q 'build-push.yml' "$PROFILE"; then
  fail "mirror profile still includes build-push.yml (use build-kaniko hybrid)"
else
  ok "no build-push in mirror profile"
fi

REG=config/mirror-services.yaml
[[ -f "$REG" ]] || fail "missing $REG"
services=$(awk '
  /^services:/{s=1; next}
  s && /^  [a-zA-Z0-9_]+:[[:space:]]*$/ { n=$1; sub(/:$/,"",n); print n }
  s && /^[^ ]/ { s=0 }
' "$REG")
for svc in $services; do
  out=$(CI_COMMIT_TAG="${svc}/v0.0.0-validate" MIRROR_SERVICES="$REG" sh scripts/resolve-mirror-service.sh --print 2>&1) || {
    fail "resolve failed for $svc: $out"
    continue
  }
  echo "$out" | grep -q "SERVICE_NAME=$svc" || fail "resolve print missing SERVICE_NAME=$svc ($out)"
  ok "resolve $svc"
  # API path without tag
  out2=$(SERVICE_NAME="$svc" SOURCE_REF="1.2.3" MIRROR_SERVICES="$REG" sh scripts/resolve-mirror-service.sh --print 2>&1) || {
    fail "resolve SERVICE_NAME-only failed for $svc: $out2"
    continue
  }
  echo "$out2" | grep -q "SOURCE_REF=1.2.3" || fail "API SOURCE_REF not honored ($out2)"
  ok "resolve API vars $svc"
done

for s in \
  scripts/mirror-inventory-services.py \
  scripts/mirror-baseline-trigger.sh \
  scripts/mirror-sync-sources.py \
  scripts/mirror-prune-hotfix-tags.sh \
  scripts/kaniko-mirror-build.sh \
  scripts/discover-openapi.sh \
  scripts/run-schemathesis-mirror.sh \
  scripts/run-dast-zap-api-mirror.sh
do
  [[ -f "$s" ]] || fail "missing $s"
  ok "present $s"
done

grep -q 'run-dast-zap-api-mirror.sh' scripts/point-copy-mirror.sh || fail "point-copy missing run-dast-zap-api-mirror.sh"
ok "point-copy lists run-dast-zap-api-mirror"

[[ -f docs/runbooks/mirror-baseline-inventory.md ]] || fail "missing baseline runbook"
[[ -f docs/runbooks/mirror-api-trigger-schemathesis.md ]] || fail "missing API/fuzz runbook"
[[ -f docs/runbooks/mirror-registry-retention.md ]] || fail "missing retention runbook"
[[ -f docs/runbooks/mirror-binary-fuzz-backlog.md ]] || fail "missing T6 backlog doc"
ok "runbooks present"

heredoc_hits=$(grep -RIn --include='*.yml' -E '^python3 <<|^python <<' templates/gitlab/jobs templates/profiles 2>/dev/null || true)
if [[ -n "$heredoc_hits" ]]; then
  echo "$heredoc_hits"
  fail "col-0 python heredoc in job YAML — use external scripts"
else
  ok "no col-0 python heredoc in job YAML"
fi

[[ -f scripts/point-copy-mirror.sh ]] || fail "missing point-copy-mirror.sh"
ok "point-copy-mirror.sh present"

if [[ "$FAIL" -ne 0 ]]; then
  echo "validate-mirror-corp: FAILED"
  exit 1
fi
echo "validate-mirror-corp: OK"
exit 0
