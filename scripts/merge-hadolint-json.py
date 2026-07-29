#!/usr/bin/env python3
"""Merge hadolint -f json part files into hadolint-report.json."""
from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <parts_dir> <out.json>", file=sys.stderr)
        return 2
    root = Path(sys.argv[1])
    out = Path(sys.argv[2])
    merged = []
    for p in sorted(root.glob("*.json")):
        try:
            data = json.loads(p.read_text(encoding="utf-8") or "[]")
        except json.JSONDecodeError:
            data = []
        if isinstance(data, list):
            merged.extend(data)
        elif data:
            merged.append(data)
    out.write_text(json.dumps(merged, indent=2) + "\n", encoding="utf-8")
    print(f"[dockerfile] merged findings={len(merged)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
