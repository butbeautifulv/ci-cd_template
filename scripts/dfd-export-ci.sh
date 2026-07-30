#!/usr/bin/env sh
# Export DFD/THREAT bundle for mirror pipeline artifacts.
set -eu

if [ -z "${SERVICE_NAME:-}" ]; then
  echo "[dfd] ERROR: SERVICE_NAME is required" >&2
  exit 1
fi

DFD_OUT_DIR="${DFD_OUT_DIR:-reports/dfd/${SERVICE_NAME}}"
mkdir -p "${DFD_OUT_DIR}"

if ! command -v dot >/dev/null 2>&1; then
  echo "[dfd] ERROR: Graphviz binary 'dot' not found in PATH" >&2
  exit 1
fi
if ! python3 -c "import importlib.util,sys; sys.exit(0 if importlib.util.find_spec('graphviz') else 1)"; then
  echo "[dfd] ERROR: python module 'graphviz' not installed" >&2
  exit 1
fi

echo "[dfd] rendering all diagrams with graphviz runtime"
python3 diagrams/main.py --export all --output-dir "${DFD_OUT_DIR}"

cat > "${DFD_OUT_DIR}/index.html" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>DFD bundle — ${SERVICE_NAME}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.4; }
    h1, h2 { margin: 0.5rem 0; }
    .muted { color: #444; font-size: 0.95rem; }
    .links a { margin-right: 12px; }
    .diag { margin: 16px 0 28px; border: 1px solid #ddd; padding: 12px; border-radius: 8px; }
    .diag img { width: 100%; height: auto; border: 1px solid #eee; }
  </style>
</head>
<body>
  <h1>DFD artifact bundle</h1>
  <p class="muted">Service: <strong>${SERVICE_NAME}</strong></p>

  <h2>Exports</h2>
  <div class="links">
    <a href="stride_register.md">stride_register.md</a>
    <a href="threat_model.json">threat_model.json</a>
    <a href="security_requirements.yaml">security_requirements.yaml</a>
  </div>

  <div class="diag">
    <h2>DFD diagram</h2>
    <div class="links"><a href="dfd_diagram.svg">open raw SVG</a></div>
    <img src="dfd_diagram.svg" alt="DFD diagram" />
  </div>
  <div class="diag">
    <h2>Architecture</h2>
    <div class="links"><a href="architecture.svg">open raw SVG</a></div>
    <img src="architecture.svg" alt="Architecture diagram" />
  </div>
  <div class="diag">
    <h2>Pipeline security</h2>
    <div class="links"><a href="pipeline_security.svg">open raw SVG</a></div>
    <img src="pipeline_security.svg" alt="Pipeline security diagram" />
  </div>
  <div class="diag">
    <h2>K8s deploy</h2>
    <div class="links"><a href="k8s_deploy.svg">open raw SVG</a></div>
    <img src="k8s_deploy.svg" alt="K8s deploy diagram" />
  </div>
</body>
</html>
EOF

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
test -s "${DFD_OUT_DIR}/index.html" || {
  echo "[dfd] ERROR: missing index.html" >&2
  exit 1
}

echo "[dfd] wrote ${DFD_OUT_DIR}"
