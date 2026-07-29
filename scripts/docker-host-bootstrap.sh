#!/usr/bin/env sh
# Pick DOCKER_HOST for shell executor (host socket) vs k8s+dind sidecar (TLS).
# GitLab k8s jobs with services: dind need tcp://docker:2376; shell ignores services.
set -eu

docker_wait_ready() {
  i=0
  while [ "$i" -lt 45 ]; do
    if docker info >/dev/null 2>&1; then
      echo "[docker] daemon ready"
      return 0
    fi
    i=$((i + 1))
    sleep 1
  done
  echo "[docker] WARN: daemon not ready after 45s" >&2
  return 1
}

if [ -S /var/run/docker.sock ]; then
  export DOCKER_HOST="unix:///var/run/docker.sock"
  unset DOCKER_TLS_VERIFY DOCKER_CERT_PATH 2>/dev/null || true
  echo "[docker] host socket (shell executor)"
  docker_wait_ready || true
elif [ -f "${DOCKER_TLS_CERTDIR:-/certs}/client/ca.pem" ] || [ -d "${DOCKER_TLS_CERTDIR:-/certs}/client" ]; then
  export DOCKER_HOST="${DOCKER_HOST:-tcp://docker:2376}"
  export DOCKER_TLS_CERTDIR="${DOCKER_TLS_CERTDIR:-/certs}"
  export DOCKER_TLS_VERIFY="${DOCKER_TLS_VERIFY:-1}"
  export DOCKER_CERT_PATH="${DOCKER_CERT_PATH:-$DOCKER_TLS_CERTDIR/client}"
  echo "[docker] dind TLS DOCKER_HOST=$DOCKER_HOST"
  docker_wait_ready || true
else
  echo "[docker] WARN: no docker.sock and no ${DOCKER_TLS_CERTDIR:-/certs}/client — docker may fail"
fi
