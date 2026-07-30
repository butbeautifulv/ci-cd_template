#!/usr/bin/env sh
# Export DFD/THREAT bundle via fabrica-diagrams-go (no Graphviz / Python).
set -eu

if [ -z "${SERVICE_NAME:-}" ]; then
  echo "[dfd] ERROR: SERVICE_NAME is required" >&2
  exit 1
fi

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
DFD_OUT_DIR="${DFD_OUT_DIR:-reports/dfd/${SERVICE_NAME}}"
mkdir -p "${DFD_OUT_DIR}"

BIN="${FABRICA_DIAGRAMS_GO_BIN:-}"
if [ -z "${BIN}" ]; then
  if [ -x "${ROOT}/diagrams-go/bin/fabrica-diagrams-go" ]; then
    BIN="${ROOT}/diagrams-go/bin/fabrica-diagrams-go"
  elif command -v fabrica-diagrams-go >/dev/null 2>&1; then
    BIN="$(command -v fabrica-diagrams-go)"
  fi
fi

if [ -z "${BIN}" ] || [ ! -x "${BIN}" ]; then
  if command -v go >/dev/null 2>&1 && [ -d "${ROOT}/diagrams-go" ]; then
    echo "[dfd] building fabrica-diagrams-go from source"
    BIN="${DFD_OUT_DIR}/.fabrica-diagrams-go"
    (cd "${ROOT}/diagrams-go" && CGO_ENABLED=0 go build -o "${BIN}" ./cmd/fabrica-diagrams-go)
  else
    echo "[dfd] ERROR: fabrica-diagrams-go binary not found (expected diagrams-go/bin/fabrica-diagrams-go)" >&2
    exit 1
  fi
fi

echo "[dfd] rendering DFD bundle with ${BIN}"
"${BIN}" \
  --output-dir "${DFD_OUT_DIR}" \
  --only dfd \
  --export all \
  --service-name "${SERVICE_NAME}"

test -s "${DFD_OUT_DIR}/dfd_diagram.svg" || {
  echo "[dfd] ERROR: missing dfd_diagram.svg" >&2
  exit 1
}
grep -q '<svg' "${DFD_OUT_DIR}/dfd_diagram.svg" || {
  echo "[dfd] ERROR: dfd_diagram.svg is not valid SVG" >&2
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
test -s "${DFD_OUT_DIR}/security_requirements.yaml" || {
  echo "[dfd] ERROR: missing security_requirements.yaml" >&2
  exit 1
}
test -s "${DFD_OUT_DIR}/index.html" || {
  echo "[dfd] ERROR: missing index.html" >&2
  exit 1
}

echo "[dfd] wrote ${DFD_OUT_DIR}"
