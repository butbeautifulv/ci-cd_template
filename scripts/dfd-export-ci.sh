#!/usr/bin/env sh
# Export DFD/THREAT bundle for mirror pipeline artifacts.
set -eu

if [ -z "${SERVICE_NAME:-}" ]; then
  echo "[dfd] ERROR: SERVICE_NAME is required" >&2
  exit 1
fi

DFD_OUT_DIR="${DFD_OUT_DIR:-reports/dfd/${SERVICE_NAME}}"
mkdir -p "${DFD_OUT_DIR}"

if command -v dot >/dev/null 2>&1 && python3 -c "import importlib.util,sys; sys.exit(0 if importlib.util.find_spec('graphviz') else 1)"; then
  echo "[dfd] rendering all diagrams with graphviz runtime"
  python3 diagrams/main.py --export all --output-dir "${DFD_OUT_DIR}"
else
  echo "[dfd] graphviz runtime missing; fallback to lightweight generated bundle"
  TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  for n in dfd_diagram architecture pipeline_security k8s_deploy; do
    cat > "${DFD_OUT_DIR}/${n}.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="260">
  <rect x="8" y="8" width="1184" height="244" fill="#ffffff" stroke="#111111" stroke-width="2"/>
  <text x="24" y="48" font-size="26" font-family="Arial, sans-serif">${n}</text>
  <text x="24" y="92" font-size="18" font-family="Arial, sans-serif">service: ${SERVICE_NAME}</text>
  <text x="24" y="126" font-size="18" font-family="Arial, sans-serif">mode: fallback (graphviz runtime missing)</text>
  <text x="24" y="160" font-size="16" font-family="Arial, sans-serif">source: fabrica diagrams bundle in CI</text>
  <text x="24" y="194" font-size="14" font-family="Arial, sans-serif">generated_utc: ${TS}</text>
</svg>
EOF
  done
  cat > "${DFD_OUT_DIR}/stride_register.md" <<EOF
# STRIDE register (fallback)

- service: ${SERVICE_NAME}
- generated_utc: ${TS}
- note: Graphviz runtime unavailable; fallback bundle produced.
EOF
  cat > "${DFD_OUT_DIR}/threat_model.json" <<EOF
{"service":"${SERVICE_NAME}","generated_utc":"${TS}","mode":"fallback","note":"Graphviz runtime unavailable; fallback bundle produced"}
EOF
  cat > "${DFD_OUT_DIR}/security_requirements.yaml" <<EOF
service: ${SERVICE_NAME}
generated_utc: "${TS}"
mode: fallback
note: "Graphviz runtime unavailable; fallback bundle produced"
EOF
fi

test -s "${DFD_OUT_DIR}/dfd_diagram.svg" || {
  echo "[dfd] ERROR: missing dfd_diagram.svg" >&2
  exit 1
}
test -s "${DFD_OUT_DIR}/stride_register.md" || {
  echo "[dfd] ERROR: missing stride_register.md" >&2
  exit 1
}
test -s "${DFD_OUT_DIR}/threat_model.json" || {
  echo "[dfd] ERROR: missing threat_model.json" >&2
  exit 1
}

echo "[dfd] wrote ${DFD_OUT_DIR}"
