#!/usr/bin/env bash
# Regenerate OSS pin mirrors from config/oss-tool-versions.yaml
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
python3 scripts/generate-oss-pins.py
