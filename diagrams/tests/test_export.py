"""Tests for threat modeling artifact exports."""

from __future__ import annotations

import json
from pathlib import Path

from diagrams.requirements_export import export_requirements_json, export_requirements_yaml
from diagrams.stride_export import export_stride_md, iter_threats
from diagrams.threat_dragon_export import export_threat_dragon_json


def test_iter_threats_non_empty() -> None:
    threats = iter_threats()
    assert len(threats) > 0
    assert threats[0]["id"].startswith("T-")


def test_export_stride_md(tmp_path: Path) -> None:
    path = export_stride_md(tmp_path / "stride_register.md")
    content = path.read_text(encoding="utf-8")
    assert "# STRIDE Threat Register" in content
    assert "| T-" in content
    assert "Spoofing" in content


def test_export_threat_dragon_json(tmp_path: Path) -> None:
    path = export_threat_dragon_json(tmp_path / "threat_model.json")
    data = json.loads(path.read_text(encoding="utf-8"))
    assert data["version"] == "2.2.0"
    assert data["detail"]["diagrams"]
    assert data["detail"]["threatTop"] > 0
    cell = data["detail"]["diagrams"][0]["cells"][0]
    assert cell["threats"]


def test_export_requirements_yaml(tmp_path: Path) -> None:
    path = export_requirements_yaml(tmp_path / "security_requirements.yaml")
    content = path.read_text(encoding="utf-8")
    assert "requirements:" in content
    assert "threat_ref:" in content
    assert "fabrica_control:" in content


def test_export_requirements_json(tmp_path: Path) -> None:
    path = export_requirements_json(tmp_path / "security_requirements.json")
    data = json.loads(path.read_text(encoding="utf-8"))
    assert len(data["requirements"]) > 0
    assert data["requirements"][0]["id"].startswith("SR-")
