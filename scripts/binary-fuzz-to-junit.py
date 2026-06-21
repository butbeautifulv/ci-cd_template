#!/usr/bin/env python3
"""Write aggregated JUnit XML for binary fuzz engines (AFL++, Go, Jazzer)."""
from __future__ import annotations

import argparse
import xml.etree.ElementTree as ET
from pathlib import Path


def main() -> int:
    p = argparse.ArgumentParser(description="Aggregate binary fuzz results to JUnit XML")
    p.add_argument("-o", "--output", required=True, type=Path)
    p.add_argument(
        "--result",
        action="append",
        default=[],
        help="engine:pass|fail|error[:message]",
    )
    args = p.parse_args()

    failures = errors = tests = 0
    root = ET.Element("testsuites")
    suite = ET.SubElement(root, "testsuite", name="binary-fuzz")

    for raw in args.result:
        parts = raw.split(":", 2)
        if len(parts) < 2:
            continue
        engine, status = parts[0], parts[1]
        message = parts[2] if len(parts) > 2 else ""
        tests += 1
        case = ET.SubElement(suite, "testcase", name=engine, classname="binary_fuzz")
        if status == "fail":
            failures += 1
            ET.SubElement(case, "failure", message=message or f"{engine} reported crashes")
        elif status == "error":
            errors += 1
            ET.SubElement(case, "error", message=message or f"{engine} failed to run")

    suite.set("tests", str(tests))
    suite.set("failures", str(failures))
    suite.set("errors", str(errors))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    tree = ET.ElementTree(root)
    if hasattr(ET, "indent"):
        ET.indent(tree, space="  ")
    tree.write(args.output, encoding="unicode", xml_declaration=True)
    return 1 if (failures or errors) else 0


if __name__ == "__main__":
    raise SystemExit(main())
