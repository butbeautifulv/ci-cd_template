#!/usr/bin/env bash
# Fail if generated OSS pin files diverge from config/oss-tool-versions.yaml
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cp templates/gitlab/jobs/oss/versions.yml "$TMP/versions.yml.bak"
cp config/github-oss-env.yml "$TMP/github-oss-env.yml.bak"
cp templates/profiles/oss-full.github.yml "$TMP/oss-full.github.yml.bak"

python3 scripts/generate-oss-pins.py >/dev/null

fail=0
for pair in \
  "$TMP/versions.yml.bak:templates/gitlab/jobs/oss/versions.yml" \
  "$TMP/github-oss-env.yml.bak:config/github-oss-env.yml" \
  "$TMP/oss-full.github.yml.bak:templates/profiles/oss-full.github.yml"
do
  old="${pair%%:*}"
  new="${pair##*:}"
  if ! diff -q "$old" "$new" >/dev/null 2>&1; then
    echo "DRIFT: $new differs from manifest (run: python3 scripts/generate-oss-pins.py)"
    diff -u "$old" "$new" | head -40 || true
    fail=1
  fi
done

# Restore originals if we modified during check
cp "$TMP/versions.yml.bak" templates/gitlab/jobs/oss/versions.yml
cp "$TMP/github-oss-env.yml.bak" config/github-oss-env.yml
cp "$TMP/oss-full.github.yml.bak" templates/profiles/oss-full.github.yml

if [[ $fail -ne 0 ]]; then
  exit 1
fi

echo "OK: OSS pin mirrors in sync with config/oss-tool-versions.yaml"
