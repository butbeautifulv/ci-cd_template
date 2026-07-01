#!/usr/bin/env bash
# Validate sample Helm chart baseline (probes, SA, resources, security).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHART="$ROOT/templates/k8s/helm/sample-app"
fail=0

report() {
  echo "VIOLATION: $1"
  fail=1
}

[[ -d "$CHART/templates" ]] || report "missing chart: $CHART"

for f in deployment.yaml serviceaccount.yaml values.yaml; do
  [[ -f "$CHART/templates/$f" || -f "$CHART/$f" ]] || report "missing $f"
done

deploy="$CHART/templates/deployment.yaml"
grep -q 'livenessProbe:' "$deploy" || report "deployment missing livenessProbe"
grep -q 'readinessProbe:' "$deploy" || report "deployment missing readinessProbe"
grep -q 'serviceAccountName:' "$deploy" || report "deployment missing serviceAccountName"
grep -q 'resources:' "$deploy" || report "deployment missing resources"
grep -q 'runAsNonRoot: true' "$deploy" || report "deployment missing runAsNonRoot"

values="$CHART/values.yaml"
if grep -qE 'tag:[[:space:]]*latest' "$values"; then
  report "values.yaml must not default image.tag to latest"
fi
grep -q 'requests:' "$values" || report "values.yaml missing resource requests"
grep -q 'limits:' "$values" || report "values.yaml missing resource limits"

if command -v helm >/dev/null 2>&1; then
  rendered="$(helm template test-release "$CHART" 2>/dev/null || true)"
  if [[ -z "$rendered" ]]; then
    report "helm template failed for sample-app chart"
  else
    echo "$rendered" | grep -q 'kind: ServiceAccount' || report "rendered manifest missing ServiceAccount"
  fi
else
  echo "SKIP: helm not installed — static checks only"
fi

if [[ $fail -ne 0 ]]; then
  echo ""
  echo "Helm chart validation failed. See docs/runbooks/k8s-workload-baseline.md"
  exit 1
fi

echo "OK: Helm sample-app chart baseline valid"
