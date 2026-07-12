"""Tests for Fabrica diagram generators."""

from __future__ import annotations

import shutil
from pathlib import Path

import pytest

from diagrams.render import ensure_output_path, require_graphviz_binary
from diagrams.dfd import render_dfd
from diagrams.architecture import render_architecture
from diagrams.pipeline import render_pipeline
from diagrams.k8s_deploy import render_k8s_deploy

dot_available = shutil.which("dot") is not None
requires_dot = pytest.mark.skipif(not dot_available, reason="Graphviz 'dot' binary not in PATH")


def test_ensure_output_path_svg() -> None:
    assert ensure_output_path("dfd_diagram.svg") == Path("dfd_diagram.svg")
    assert ensure_output_path("dfd_diagram") == Path("dfd_diagram.svg")
    assert ensure_output_path("out/dfd", fmt="png") == Path("out/dfd.png")


def test_ensure_output_path_invalid_format() -> None:
    with pytest.raises(ValueError, match="Unsupported format"):
        ensure_output_path("x", fmt="pdf")


def test_require_graphviz_binary_raises_when_missing(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setattr(shutil, "which", lambda _: None)
    with pytest.raises(RuntimeError, match="Graphviz binary"):
        require_graphviz_binary()


@requires_dot
def test_render_dfd_creates_svg(tmp_path: Path) -> None:
    path = render_dfd(tmp_path / "dfd_diagram", fmt="svg")
    assert path.exists()
    content = path.read_text(encoding="utf-8")
    assert content.lstrip().startswith(("<?xml", "<svg"))
    assert "STRIDE" in content
    assert "LINDDUN" in content


@requires_dot
def test_render_architecture_creates_svg(tmp_path: Path) -> None:
    path = render_architecture(tmp_path / "architecture", fmt="svg")
    assert path.exists()
    content = path.read_text(encoding="utf-8")
    assert "FastAPI" in content
    assert "OpenAPI" in content
    assert "SSRF" in content


@requires_dot
def test_render_pipeline_creates_svg(tmp_path: Path) -> None:
    path = render_pipeline(tmp_path / "pipeline", fmt="svg")
    assert path.exists()


@requires_dot
def test_render_k8s_deploy_creates_svg(tmp_path: Path) -> None:
    path = render_k8s_deploy(tmp_path / "k8s", fmt="svg")
    assert path.exists()
