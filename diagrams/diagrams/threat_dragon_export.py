"""Export OWASP Threat Dragon 2.x JSON threat model."""

from __future__ import annotations

import json
import uuid
from pathlib import Path

from diagrams.model import (
    FASTAPI_DFD_ELEMENTS,
    THREAT_MODEL_DESCRIPTION,
    THREAT_MODEL_TITLE,
)
from diagrams.stride_constants import STRIDE_BY_ELEMENT, STRIDE_MITIGATIONS

TYPE_MAP = {
    "process": "tm.Process",
    "data_store": "tm.Store",
    "data_flow": "tm.Flow",
    "external_entity": "tm.Actor",
    "trust_boundary": "tm.Boundary",
}


def export_threat_dragon_json(output_path: str | Path) -> Path:
    """Build Threat Dragon JSON with STRIDE threats applied to DFD elements."""
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)

    cells: list[dict] = []
    element_ids: dict[str, str] = {}
    threat_counter = 0

    x_positions = {"app": 200, "external": 500}
    y = 80
    for element in FASTAPI_DFD_ELEMENTS:
        element_uuid = str(uuid.uuid4())
        element_ids[element.id] = element_uuid
        x = x_positions.get(element.cluster, 200)
        cell: dict = {
            "type": TYPE_MAP[element.element_type.value],
            "id": element_uuid,
            "name": element.name,
            "description": element.description,
            "position": {"x": x, "y": y},
            "size": {"width": 120, "height": 60},
            "threats": [],
            "hasOpenThreats": False,
        }
        y += 90

        for category in STRIDE_BY_ELEMENT.get(element.element_type.value, []):
            threat_counter += 1
            threat = {
                "id": str(threat_counter),
                "title": f"{category} - {element.name}",
                "type": category,
                "status": "Open",
                "severity": "Medium",
                "description": f"Potential {category.lower()} threat against {element.name}",
                "mitigation": "; ".join(
                    STRIDE_MITIGATIONS.get(category, ["Review required"])
                ),
                "modelType": "STRIDE",
            }
            cell["threats"].append(threat)
            cell["hasOpenThreats"] = True

        cells.append(cell)

    model = {
        "version": "2.2.0",
        "summary": {
            "title": THREAT_MODEL_TITLE,
            "owner": "Security Team",
            "description": THREAT_MODEL_DESCRIPTION,
            "id": 0,
        },
        "detail": {
            "contributors": [],
            "diagrams": [
                {
                    "id": 0,
                    "title": "FastAPI DFD",
                    "diagramType": "STRIDE",
                    "placeholder": "New STRIDE diagram",
                    "thumbnail": "",
                    "version": "2.2.0",
                    "cells": cells,
                }
            ],
            "diagramTop": 0,
            "reviewer": "",
            "threatTop": threat_counter,
        },
    }

    path.write_text(json.dumps(model, indent=2, ensure_ascii=False), encoding="utf-8")
    return path
