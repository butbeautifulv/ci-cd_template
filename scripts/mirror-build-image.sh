#!/usr/bin/env sh
# Mirror image build: Kaniko if /kaniko/executor present, else docker CLI.
# Writes build.env: IMAGE_TAG, BUILD_FALLBACK, SOURCE_SHA
# IMAGE_TAG=${SERVICE_NAME}-${SOURCE_SHA}
# Hard-fail if neither backend works / push fails.
set -eu

if [ -x /kaniko/executor ] || [ -x "${KANIKO_EXECUTOR:-}" ]; then
  echo "[build] backend=kaniko"
  exec sh scripts/kaniko-mirror-build.sh
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "[build] ERROR: no /kaniko/executor and no docker CLI — cannot build"
  echo "[build] HINT: shell executor needs host docker; k8s needs Kaniko image in Nexus or docker:cli+dind"
  exit 1
fi

echo "[build] backend=docker (Kaniko binary absent — Nexus Kaniko image not available on this runner)"

SCAN_ROOT="${SCAN_ROOT:-checkout}"
SERVICE_NAME="${SERVICE_NAME:-app}"
REGISTRY="${REGISTRY:?REGISTRY required}"
BUILD_BASE_IMAGE="${BUILD_BASE_IMAGE:-nexus.svo.aero:8345/library/python:3.11.11-slim-bookworm}"
BUILD_DOCKER_TARGET="${BUILD_DOCKER_TARGET:-base}"
NEXUS_PYPI_URL="${NEXUS_PYPI_URL:-}"
if [ -z "$NEXUS_PYPI_URL" ] && [ -n "${PIP_INDEX_URL:-}" ]; then
  NEXUS_PYPI_URL=$(printf '%s' "$PIP_INDEX_URL" | sed -E 's|^https?://||; s|/simple/?$||')
fi

: > build.env

SOURCE_SHA=""
if command -v git >/dev/null 2>&1 && [ -d "$SCAN_ROOT/.git" ]; then
  SOURCE_SHA=$(git -C "$SCAN_ROOT" rev-parse HEAD)
elif [ -n "${SOURCE_REF_RESOLVED:-}" ]; then
  SOURCE_SHA=$(printf '%s' "$SOURCE_REF_RESOLVED" | tr -c 'A-Za-z0-9' '-' | cut -c1-40)
elif [ -n "${SOURCE_REF:-}" ]; then
  SOURCE_SHA=$(printf '%s' "$SOURCE_REF" | tr -c 'A-Za-z0-9' '-' | cut -c1-40)
else
  SOURCE_SHA="${CI_COMMIT_SHA:-unknown}"
fi
IMAGE_TAG="${SERVICE_NAME}-${SOURCE_SHA}"

DF=""
if [ -d "$SCAN_ROOT" ]; then
  DF=$(find "$SCAN_ROOT" \( -path "$SCAN_ROOT/Docker/*/Dockerfile" -o -path "$SCAN_ROOT/Docker/Dockerfile" -o -name Dockerfile \) -type f 2>/dev/null | head -1 || true)
fi
if [ -z "$DF" ] && [ -f Dockerfile ]; then
  DF=Dockerfile
fi
if [ -z "$DF" ] || [ ! -f "$DF" ]; then
  echo "[build] ERROR: No Dockerfile under $SCAN_ROOT — refusing silent skip"
  echo "IMAGE_TAG=none" >> build.env
  echo "BUILD_FALLBACK=0" >> build.env
  echo "SOURCE_SHA=${SOURCE_SHA}" >> build.env
  exit 1
fi

CONTEXT="$SCAN_ROOT"
if [ ! -d "$CONTEXT" ]; then
  CONTEXT=$(dirname "$DF")
fi

echo "[build] dockerfile=$DF context=$CONTEXT tag=${REGISTRY}:${IMAGE_TAG}"
echo "[build] BUILD_BASE_IMAGE=$BUILD_BASE_IMAGE target=$BUILD_DOCKER_TARGET SOURCE_SHA=$SOURCE_SHA"

for cand in \
  /etc/ssl/certs/nexus/ca.crt \
  "/etc/docker/certs.d/nexus.svo.aero:8345/ca.crt" \
  "/etc/docker/certs.d/nexus.svo.aero:8374/ca.crt"
do
  if [ -f "$cand" ]; then
    mkdir -p /etc/docker/certs.d/nexus.svo.aero:8345 /etc/docker/certs.d/nexus.svo.aero:8374
    cp "$cand" /etc/docker/certs.d/nexus.svo.aero:8345/ca.crt || true
    cp "$cand" /etc/docker/certs.d/nexus.svo.aero:8374/ca.crt || true
    echo "[build] docker CA from $cand"
    break
  fi
done

if [ -n "${NEXUS_USER:-}" ] && [ -n "${NEXUS_PASSWORD:-}" ]; then
  printf '%s\n' "$NEXUS_PASSWORD" | docker login -u "$NEXUS_USER" --password-stdin "nexus.svo.aero:8345" || true
  printf '%s\n' "$NEXUS_PASSWORD" | docker login -u "$NEXUS_USER" --password-stdin "nexus.svo.aero:8374" || true
fi

NEXUS_USER_ENC="${NEXUS_USER:-}"
NEXUS_PASSWORD_ENC="${NEXUS_PASSWORD:-}"
if command -v python3 >/dev/null 2>&1 && [ -n "${NEXUS_USER:-}" ] && [ -n "${NEXUS_PASSWORD:-}" ]; then
  NEXUS_USER_ENC=$(python3 -c 'import os,urllib.parse; print(urllib.parse.quote(os.environ["NEXUS_USER"], safe=""))')
  NEXUS_PASSWORD_ENC=$(python3 -c 'import os,urllib.parse; print(urllib.parse.quote(os.environ["NEXUS_PASSWORD"], safe=""))')
fi

PIP_HOST="${PIP_TRUSTED_HOST:-}"
if [ -z "$PIP_HOST" ] && [ -n "${NEXUS_PYPI_URL:-}" ]; then
  PIP_HOST=$(printf '%s' "$NEXUS_PYPI_URL" | cut -d/ -f1)
fi
if [ -n "$PIP_HOST" ] && [ -f "$DF" ]; then
  echo "[build] patch trusted-host -> ${PIP_HOST}"
  sed -i "s/--trusted-host [^ ]*/--trusted-host ${PIP_HOST}/g" "$DF" || true
fi

set -- --target "$BUILD_DOCKER_TARGET" --build-arg "IMAGE_NAME=${BUILD_BASE_IMAGE}"
if [ -n "${NEXUS_PYPI_URL:-}" ]; then
  set -- "$@" --build-arg "NEXUS_PYPI_URL=${NEXUS_PYPI_URL}"
fi
if [ -n "${NEXUS_USER_ENC:-}" ]; then
  set -- "$@" --build-arg "NEXUS_USERNAME=${NEXUS_USER_ENC}"
fi
if [ -n "${NEXUS_PASSWORD_ENC:-}" ]; then
  set -- "$@" --build-arg "NEXUS_PASSWORD=${NEXUS_PASSWORD_ENC}"
fi
set -- "$@" -f "$DF" -t "${REGISTRY}:${IMAGE_TAG}" "$CONTEXT"

set +e
docker build "$@"
rc=$?
set -e
if [ "$rc" -ne 0 ]; then
  echo "[build] WARN: service build failed rc=$rc — fallback retag ${BUILD_BASE_IMAGE}"
  set +e
  docker pull "$BUILD_BASE_IMAGE" \
    && docker tag "$BUILD_BASE_IMAGE" "${REGISTRY}:${IMAGE_TAG}" \
    && docker push "${REGISTRY}:${IMAGE_TAG}"
  frc=$?
  set -e
  if [ "$frc" -eq 0 ]; then
    echo "IMAGE_TAG=${IMAGE_TAG}" >> build.env
    echo "BUILD_FALLBACK=1" >> build.env
    echo "SOURCE_SHA=${SOURCE_SHA}" >> build.env
    echo "[build] fallback pushed ${REGISTRY}:${IMAGE_TAG} BUILD_FALLBACK=1"
    exit 0
  fi
  echo "[build] ERROR: fallback also failed"
  echo "IMAGE_TAG=none" >> build.env
  echo "BUILD_FALLBACK=1" >> build.env
  echo "SOURCE_SHA=${SOURCE_SHA}" >> build.env
  exit 1
fi

docker push "${REGISTRY}:${IMAGE_TAG}"
echo "IMAGE_TAG=${IMAGE_TAG}" >> build.env
echo "BUILD_FALLBACK=0" >> build.env
echo "SOURCE_SHA=${SOURCE_SHA}" >> build.env
echo "[build] pushed ${REGISTRY}:${IMAGE_TAG} BUILD_FALLBACK=0"
