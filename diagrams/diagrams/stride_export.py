"""Export STRIDE threat register as Markdown."""

from __future__ import annotations

from pathlib import Path

from diagrams.model import FASTAPI_DFD_ELEMENTS, THREAT_MODEL_TITLE
from diagrams.stride_constants import (
    DEFAULT_RISK_LEVEL,
    STRIDE_ABBREV,
    STRIDE_BY_ELEMENT,
    STRIDE_MITIGATIONS,
)


def _threat_rows() -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    counter = 0
    for element in FASTAPI_DFD_ELEMENTS:
        key = element.element_type.value
        for category in STRIDE_BY_ELEMENT.get(key, []):
            counter += 1
            abbrev = STRIDE_ABBREV.get(category, category[0])
            mitigations = STRIDE_MITIGATIONS.get(category, ["Review required"])
            rows.append(
                {
                    "id": f"T-{abbrev}-{counter:03d}",
                    "element": element.name,
                    "stride": category,
                    "description": f"Potential {category.lower()} against {element.name}",
                    "risk": DEFAULT_RISK_LEVEL,
                    "mitigation": "; ".join(mitigations),
                    "fabrica_control": ", ".join(element.fabrica_controls) or "—",
                    "status": "Open",
                }
            )
    return rows


def export_stride_md(output_path: str | Path) -> Path:
    """Write stride_register.md from the canonical DFD model."""
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    rows = _threat_rows()

    lines = [
        f"# STRIDE Threat Register — {THREAT_MODEL_TITLE}",
        "",
        "| ID | Element | STRIDE | Description | Risk | Mitigation | Fabrica | Status |",
        "|----|---------|--------|-------------|------|------------|---------|--------|",
    ]
    for row in rows:
        lines.append(
            f"| {row['id']} | {row['element']} | {row['stride']} | {row['description']} "
            f"| {row['risk']} | {row['mitigation']} | {row['fabrica_control']} | {row['status']} |"
        )
    lines.extend(["", "_Risk stub: Impact × Likelihood (1–4); default Medium for workshop._", ""])
    path.write_text("\n".join(lines), encoding="utf-8")
    return path


def iter_threats() -> list[dict[str, str]]:
    """Return threat rows for other exporters."""
    return _threat_rows()
