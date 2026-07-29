#!/bin/sh
# Fetch a GitLab project archive into dest (corp offline; no apt/apk).
# Same contract as fetch-source-archive.py — for alpine/hadolint images without python.
#
# Usage:
#   fetch-source-archive.sh <api_v4_url> <project_id> <ref> <dest> <token>
# Env:
#   SOURCE_SSL_NO_VERIFY=1  — curl -k (corp MITM)

set -eu

if [ "$#" -ne 5 ]; then
  echo "usage: fetch-source-archive.sh <api> <project_id> <ref> <dest> <token>" >&2
  exit 2
fi

API="$1"
PID="$2"
REF="$3"
DEST="$4"
TOKEN="$5"

# Don't leak token contents, only whether it's set.
TOKEN_SET=0
if [ -n "${TOKEN:-}" ]; then TOKEN_SET=1; fi
echo "[fetch] token_set=${TOKEN_SET} pid=$PID ref=$REF dest=$DEST" >&2

# URL-encode ref lightly (tags like 0.0.4 are fine; hotfix tags need %2F for slashes)
REF_ENC=$(printf '%s' "$REF" | sed 's|/|%2F|g')
URL="${API%/}/projects/${PID}/repository/archive.tar.gz?sha=${REF_ENC}"

CURL_OPTS="-sS -L --max-time 120"
case "${SOURCE_SSL_NO_VERIFY:-}" in
  1|true|yes|TRUE|YES) CURL_OPTS="$CURL_OPTS -k" ;;
esac

if ! command -v tar >/dev/null 2>&1; then
  echo "fetch-source-archive.sh: tar required" >&2
  exit 1
fi
# Prefer curl; wget is enough on alpine/hadolint images without curl.
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  echo "fetch-source-archive.sh: curl or wget required" >&2
  exit 1
fi

# Kaniko images may not have /tmp inside the filesystem.
# Ensure a usable temp dir before mktemp runs.
TMPDIR="${TMPDIR:-/tmp}"
mkdir -p "${TMPDIR}" 2>/dev/null || true
TMP=$(mktemp -d -p "${TMPDIR}")
trap 'rm -rf "$TMP"' EXIT

# shellcheck disable=SC2086
if command -v curl >/dev/null 2>&1; then
  CURL_ERR="$TMP/curl.err"
  rm -f "$CURL_ERR" 2>/dev/null || true
  HTTP_CODE="$(curl $CURL_OPTS \
    -H "PRIVATE-TOKEN: ${TOKEN}" \
    -o "$TMP/archive.tar.gz" \
    -w '%{http_code}' \
    "$URL" 2>"$CURL_ERR" || true)"
  if [ "$HTTP_CODE" != "200" ]; then
    echo "archive fetch failed: $URL http=${HTTP_CODE:-<unset>}" >&2
    if [ -s "$CURL_ERR" ]; then
      echo "curl_err_snip:" >&2
      tail -n 30 "$CURL_ERR" >&2 || true
    fi
    exit 1
  fi
else
  # alpine/hadolint: busybox wget (no curl)
  WGET_OPTS="-S -O"
  case "${SOURCE_SSL_NO_VERIFY:-}" in
    1|true|yes|TRUE|YES) WGET_OPTS="--no-check-certificate $WGET_OPTS" ;;
  esac
  WGET_ERR="$TMP/wget.err"
  WGET_OUT="$TMP/wget.out"
  rm -f "$WGET_ERR" "$WGET_OUT" 2>/dev/null || true
  # shellcheck disable=SC2086
  if ! wget $WGET_OPTS "$TMP/archive.tar.gz" --header="PRIVATE-TOKEN: ${TOKEN}" "$URL" >"$WGET_OUT" 2>"$WGET_ERR"; then
    echo "archive fetch failed: $URL" >&2
    if [ -s "$WGET_ERR" ]; then
      echo "wget_err_snip:" >&2
      tail -n 40 "$WGET_ERR" >&2 || true
    fi
    if [ -s "$WGET_OUT" ]; then
      echo "wget_out_snip:" >&2
      tail -n 40 "$WGET_OUT" >&2 || true
    fi
    exit 1
  fi
fi

rm -rf "$DEST"
mkdir -p "$TMP/extract" "$DEST"
tar -xzf "$TMP/archive.tar.gz" -C "$TMP/extract"
# GitLab archive has a single top-level directory
ROOT=$(find "$TMP/extract" -mindepth 1 -maxdepth 1 -type d | head -1)
if [ -z "$ROOT" ]; then
  echo "empty archive" >&2
  exit 1
fi
# Copy contents (not the wrapper dir) into DEST
# portable: tar pipe
tar -C "$ROOT" -cf - . | tar -C "$DEST" -xf -
echo "archive_ok $DEST"
