#!/usr/bin/env python3
"""Synthesize bandit.sarif from bandit JSON (-f json) when SARIF format is unavailable."""
from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <bandit.json> <bandit.sarif>", file=sys.stderr)
        return 2
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    findings = json.loads(src.read_text(encoding="utf-8"))
    results = []
    for r in findings.get("results") or []:
        sev = str(r.get("issue_severity") or "").upper()
        level = "error" if sev in ("HIGH", "CRITICAL") else "warning"
        results.append(
            {
                "ruleId": r.get("test_id") or r.get("test_name") or "bandit",
                "level": level,
                "message": {"text": r.get("issue_text") or r.get("test_name") or "bandit"},
                "locations": [
                    {
                        "physicalLocation": {
                            "artifactLocation": {"uri": r.get("filename") or ""},
                            "region": {"startLine": int(r.get("line_number") or 1)},
                        }
                    }
                ],
            }
        )
    sarif = {
        "version": "2.1.0",
        "runs": [{"tool": {"driver": {"name": "bandit"}}, "results": results}],
    }
    dst.write_text(json.dumps(sarif, indent=2) + "\n", encoding="utf-8")
    print(f"[bandit] synthesized sarif results={len(results)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
