#!/usr/bin/env python3
"""Wrap ruff text output into a minimal SARIF (ancient ruff lacks --output-format sarif).

Usage: synthesize-ruff-sarif.py <ruff-text-file> <out.sarif>
"""
from __future__ import annotations

import json
import pathlib
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: synthesize-ruff-sarif.py <ruff.txt> <out.sarif>", file=sys.stderr)
        return 2
    src = pathlib.Path(sys.argv[1])
    dest = pathlib.Path(sys.argv[2])
    text = src.read_text(errors="replace") if src.is_file() else ""
    results = []
    for line in text.splitlines():
        if not line.strip():
            continue
        results.append(
            {
                "ruleId": "ruff",
                "level": "warning",
                "message": {"text": line[:500]},
                "locations": [
                    {"physicalLocation": {"artifactLocation": {"uri": "checkout"}}}
                ],
            }
        )
    sarif = {
        "version": "2.1.0",
        "runs": [{"tool": {"driver": {"name": "ruff"}}, "results": results}],
    }
    dest.write_text(json.dumps(sarif))
    print("synthesized", len(results), "results")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
