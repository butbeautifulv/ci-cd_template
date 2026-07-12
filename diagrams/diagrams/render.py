"""Graphviz render helpers."""

from __future__ import annotations

import shutil
from pathlib import Path

import graphviz

SUPPORTED_FORMATS = frozenset({"svg", "png"})


def ensure_output_path(name: str | Path, fmt: str = "svg") -> Path:
    """Normalize output filename with the requested extension."""
    if fmt not in SUPPORTED_FORMATS:
        raise ValueError(f"Unsupported format {fmt!r}; use one of {sorted(SUPPORTED_FORMATS)}")

    path = Path(name)
    base = path.stem if path.suffix else (str(path) or "diagram")
    if not base:
        base = "diagram"
    return path.with_name(f"{base}.{fmt}") if path.suffix else Path(f"{base}.{fmt}")


def require_graphviz_binary() -> None:
    """Fail fast when the Graphviz ``dot`` binary is missing."""
    if shutil.which("dot") is None:
        raise RuntimeError(
            "Graphviz binary 'dot' not found in PATH. "
            "Install system Graphviz (e.g. apt install graphviz / brew install graphviz)."
        )


def render_diagram(dot_string: str, out_name: str | Path, *, fmt: str = "svg") -> Path:
    """Render DOT source to SVG or PNG."""
    require_graphviz_binary()
    path = ensure_output_path(out_name, fmt)
    path.parent.mkdir(parents=True, exist_ok=True)

    source = graphviz.Source(dot_string)
    rendered = source.render(
        filename=str(path.with_suffix("")),
        format=fmt,
        cleanup=True,
    )
    return Path(rendered)
