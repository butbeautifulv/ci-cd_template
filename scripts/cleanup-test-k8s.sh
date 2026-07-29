#!/usr/bin/env sh
# Remove ephemeral test namespace created by deploy-test-k8s.sh.
# Called with when: always — must not block pipeline on failure.
#
# Required env:
#   CI_PIPELINE_ID — set by GitLab CI
set -eu

NS="ci-test-${CI_PIPELINE_ID:?CI_PIPELINE_ID is required}"
echo "[cleanup] deleting namespace $NS"
kubectl delete namespace "$NS" --ignore-not-found --timeout=60s 2>&1 || true

if kubectl get namespace "$NS" >/dev/null 2>&1; then
  echo "[cleanup] WARN: namespace $NS still present after delete"
  kubectl get namespace "$NS" -o wide 2>/dev/null || true
else
  echo "[cleanup] verified: namespace $NS gone"
fi
echo "[cleanup] done"
