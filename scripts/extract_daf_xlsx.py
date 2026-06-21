#!/usr/bin/env python3
"""Extract rows from DAF_public_RU.xlsx without openpyxl."""
import argparse
import re
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
REL_NS = "{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"
DEFAULT_XLSX: Path | None = None
DEFAULT_OUTPUT = Path("docs/references/extracts/daf")


def col_index(ref: str) -> int:
    m = re.match(r"([A-Z]+)", ref)
    if not m:
        return 0
    n = 0
    for ch in m.group(1):
        n = n * 26 + (ord(ch) - 64)
    return n


def list_sheets(z: zipfile.ZipFile) -> list[str]:
    wb = ET.fromstring(z.read("xl/workbook.xml"))
    return [s.get("name", "") for s in wb.findall(".//m:sheet", NS)]


def read_sheet(z: zipfile.ZipFile, sheet_name: str) -> list[list[str]]:
    wb = ET.fromstring(z.read("xl/workbook.xml"))
    sheets = [(s.get("name"), s.get(REL_NS)) for s in wb.findall(".//m:sheet", NS)]
    rels = ET.fromstring(z.read("xl/_rels/workbook.xml.rels"))
    rid_map = {r.get("Id"): r.get("Target") for r in rels}

    target = None
    names = []
    for name, rid in sheets:
        names.append(name)
        if name == sheet_name:
            target = "xl/" + rid_map[rid].lstrip("/")

    if not target:
        print(f"Unknown sheet: {sheet_name}", file=sys.stderr)
        print("Available:", ", ".join(names), file=sys.stderr)
        sys.exit(1)

    shared: list[str] = []
    if "xl/sharedStrings.xml" in z.namelist():
        ss = ET.fromstring(z.read("xl/sharedStrings.xml"))
        for si in ss.findall(".//m:si", NS):
            texts = [t.text or "" for t in si.iter("{http://schemas.openxmlformats.org/spreadsheetml/2006/main}t")]
            shared.append("".join(texts))

    def cell_val(c: ET.Element) -> str:
        t = c.get("t")
        v = c.find("m:v", NS)
        if v is None or v.text is None:
            return ""
        if t == "s":
            return shared[int(v.text)]
        return v.text

    sh = ET.fromstring(z.read(target))
    out: list[list[str]] = []
    for row in sh.findall(".//m:row", NS):
        cells: dict[int, str] = {}
        for c in row.findall("m:c", NS):
            ref = c.get("r", "")
            cells[col_index(ref)] = cell_val(c)
        if not cells:
            continue
        max_i = max(cells)
        out.append([cells.get(i, "") for i in range(1, max_i + 1)])
    return out


def sanitize_filename(name: str) -> str:
    return re.sub(r"[^\w\-]+", "_", name, flags=re.UNICODE).strip("_") or "sheet"


def rows_to_markdown(sheet_name: str, rows: list[list[str]]) -> str:
    lines = [f"# DAF extract: {sheet_name}", "", f"Source: `DAF_public_RU.xlsx` sheet `{sheet_name}`.", ""]
    if not rows:
        lines.append("_Empty sheet._")
        return "\n".join(lines) + "\n"

    header = rows[0]
    lines.append("| " + " | ".join(c.replace("|", "\\|") for c in header) + " |")
    lines.append("| " + " | ".join("---" for _ in header) + " |")
    for row in rows[1:]:
        padded = row + [""] * (len(header) - len(row))
        lines.append("| " + " | ".join(c.replace("|", "\\|").replace("\n", " ") for c in padded[: len(header)]) + " |")
    return "\n".join(lines) + "\n"


def write_sheet_md(output_dir: Path, sheet_name: str, rows: list[list[str]]) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    path = output_dir / f"{sanitize_filename(sheet_name)}.md"
    path.write_text(rows_to_markdown(sheet_name, rows), encoding="utf-8")
    return path


def main() -> None:
    p = argparse.ArgumentParser(description="Extract DAF xlsx sheet rows")
    p.add_argument("--xlsx", type=Path, default=DEFAULT_XLSX, required=False)
    p.add_argument("--sheet", default="")
    p.add_argument("--rows", type=int, default=0, help="Max rows (0=all)")
    p.add_argument("--grep", default="", help="Filter rows containing substring")
    p.add_argument("--output-dir", type=Path, default=None)
    p.add_argument("--all-sheets", action="store_true")
    args = p.parse_args()

    if not args.xlsx or not args.xlsx.exists():
        print("Pass --xlsx /path/to/DAF_public_RU.xlsx (vendor file, not in git)", file=sys.stderr)
        sys.exit(1)

    with zipfile.ZipFile(args.xlsx) as z:
        if args.all_sheets:
            out_dir = args.output_dir or DEFAULT_OUTPUT
            for name in list_sheets(z):
                rows = read_sheet(z, name)
                path = write_sheet_md(out_dir, name, rows)
                print(f"Wrote {path} ({len(rows)} rows)")
            return

        if not args.sheet:
            print("Available sheets:", ", ".join(list_sheets(z)), file=sys.stderr)
            sys.exit(1)

        rows = read_sheet(z, args.sheet)

    if args.grep:
        rows = [r for r in rows if args.grep in "\t".join(r)]

    if args.output_dir:
        write_sheet_md(args.output_dir, args.sheet, rows[: args.rows or len(rows)])
        return

    limit = args.rows or len(rows)
    for r in rows[:limit]:
        print("\t".join(r))


if __name__ == "__main__":
    main()
