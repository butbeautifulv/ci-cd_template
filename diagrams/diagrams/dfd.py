"""Data Flow Diagram (DFD v3) for threat modeling."""

from __future__ import annotations

from pathlib import Path

from diagrams.model import FASTAPI_DFD_ELEMENTS, FASTAPI_DFD_FLOWS, DfdElement
from diagrams.render import render_diagram

TEMPLATES_DIR = Path(__file__).resolve().parent.parent / "templates"


def build_dfd_dot() -> str:
    """Build DFD DOT from the canonical model."""
    user = next(element for element in FASTAPI_DFD_ELEMENTS if element.id == "user")
    app_nodes = [element for element in FASTAPI_DFD_ELEMENTS if element.cluster == "app"]
    ext_nodes = [
        element for element in FASTAPI_DFD_ELEMENTS if element.cluster == "external"
    ]

    app_body = "\n    ".join(
        f'{element.id} [label="{element.label}", shape={element.graph_shape}];'
        for element in app_nodes
    )
    ext_body = "\n    ".join(
        f'{element.id} [label="{element.label}", shape={element.graph_shape}];'
        for element in ext_nodes
    )
    same_rank_app = "; ".join(
        element.id for element in app_nodes if element.id != "config_store"
    )
    same_rank_ext = "; ".join(element.id for element in ext_nodes)

    flow_lines: list[str] = []
    for flow in FASTAPI_DFD_FLOWS:
        label = flow.label
        if flow.linddun and flow.id == "flow_user_auth":
            label = f"{flow.label}\\nLINDDUN: {flow.linddun}"
        attrs = [f'label="{label}"']
        if flow.cross_boundary and flow.boundary_from and flow.boundary_to:
            attrs.append(f'ltail="{flow.boundary_from}"')
            attrs.append(f'lhead="{flow.boundary_to}"')
        flow_lines.append(
            f"  {flow.source} -> {flow.target} [{', '.join(attrs)}];"
        )

    return _DOT_TEMPLATE.format(
        user=_node_line(user),
        app_body=app_body,
        ext_body=ext_body,
        same_rank_app=same_rank_app,
        same_rank_ext=same_rank_ext,
        flows="\n".join(flow_lines),
    )


def _node_line(element: DfdElement) -> str:
    return f'{element.id} [label="{element.label}", shape={element.graph_shape}]'


_DOT_TEMPLATE = """digraph DFD {{
  graph [
    rankdir="LR",
    fontname="DejaVu Sans",
    fontnames="svg",
    nodesep="0.5",
    ranksep="0.8",
    splines="polyline",
    concentrate="false",
    compound="true",
    pack="true",
    packmode="node",
    labelloc="t",
    fontsize="14",
    label="Data Flow Diagram (DFD v3)\\nTrust boundaries, typed data flows — FastAPI"
  ];
  node [fontname="DejaVu Sans", fontsize="12", margin="0.03,0.03"];
  edge [
    fontname="DejaVu Sans",
    fontsize="11",
    style="solid",
    penwidth="0.9",
    arrowhead="normal",
    arrowsize="0.9"
  ];

  {user};

  subgraph cluster_app {{
    label="Application Trust Boundary";
    style="dashed";
    color="gray50";
    margin="8";

    {app_body}

    {{ rank=same; {same_rank_app} }}
  }}

  subgraph cluster_external {{
    label="External Services";
    style="dashed";
    color="gray50";
    margin="8";

    {ext_body}

    {{ rank=same; {same_rank_ext} }}
  }}

{flows}

  Legend [shape=note, fontsize="11",
    label="Нотация:\\n- STRIDE on nodes\\n- LINDDUN on PII flow\\n- Misuse: weak OAuth, credential stuffing\\n- Abuse: token replay, SSRF via outbound API"];
}}"""


def load_dfd_dot() -> str:
    """Load external DOT template if present, else build from model."""
    template = TEMPLATES_DIR / "dfd.dot"
    if template.is_file():
        return template.read_text(encoding="utf-8")
    return build_dfd_dot()


def render_dfd(filename: str | Path, *, fmt: str = "svg") -> Path:
    """Render the DFD v3 diagram."""
    return render_diagram(load_dfd_dot(), filename, fmt=fmt)
