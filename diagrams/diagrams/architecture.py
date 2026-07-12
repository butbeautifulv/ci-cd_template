"""C4 Level 3 component diagram for a FastAPI application."""

from __future__ import annotations

from pathlib import Path

from diagrams.render import render_diagram

ARCHITECTURE_DOT = r"""digraph AppArchitecture {
  graph [
    rankdir="TB",
    fontname="DejaVu Sans",
    fontnames="svg",
    nodesep="0.5",
    ranksep="0.8",
    splines="polyline",
    concentrate="false",
    pack="true",
    packmode="node",
    labelloc="t",
    fontsize="14",
    label="C4 Level 3: Component diagram for FastAPI Application"
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

  subgraph cluster_api {
    label="Container: Python API (python3.11+, uvicorn ASGI)\nPurpose: authenticate, validate, persist, integrate";
    style="rounded";
    color="lightgreen";
    margin="8";

    FastAPIApp [label="Process: FastAPI app\n(app/main.py)\norchestrates ASGI lifecycle", shape=box, style=filled, fillcolor="palegreen"];
    APIRouter  [label="Component: API Router\n(api/v1/endpoints/*)\nroutes + Depends", shape=component, style=filled, fillcolor="lightyellow"];
    AuthModule [label="Component: Auth\ncore/security.py\nOAuth2/JWT validation", shape=component, style=filled, fillcolor="khaki"];
    Settings   [label="Component: Settings\ncore/config.py\npydantic-settings / env", shape=component, style=filled, fillcolor="orange"];
    HttpClient [label="Component: HTTP Client\nhttpx.AsyncClient\noutbound REST", shape=component, style=filled, fillcolor="cyan"];
    OpenAPIDocs [label="Component: OpenAPI /docs\nSwagger UI exposure", shape=component, style=filled, fillcolor="lightyellow"];
  }

  subgraph cluster_ext {
    label="External Systems";
    style="dashed";
    color="gray50";
    margin="8";

    PostgreSQL  [label="PostgreSQL\nasyncpg / SQLAlchemy\nasync data access", shape=cylinder, style=filled, fillcolor="gainsboro"];
    S3Storage   [label="Object Storage (S3)\nSSE, HTTPS/TLS 1.3", shape=cylinder, style=filled, fillcolor="lightgray"];
    ExternalAPI [label="External REST API\nprotocol: HTTPS/JSON", shape=box, style=filled, fillcolor="lightcoral"];
  }

  FastAPIApp -> APIRouter   [label="mount routers"];
  FastAPIApp -> OpenAPIDocs [label="expose /docs\n(abuse: info disclosure)"];
  APIRouter -> AuthModule   [label="Depends: get_current_user\n(abuse: broken auth)"];
  APIRouter -> Settings     [label="Depends: get_settings\n(abuse: secret in env/logs)"];
  APIRouter -> HttpClient   [label="async outbound\n(abuse: SSRF)"];

  APIRouter -> PostgreSQL   [label="SQL; parameterized queries"];
  APIRouter -> S3Storage    [label="S3 API; object upload/download"];
  HttpClient -> ExternalAPI [label="HTTPS/TLS 1.3; JSON; cert verify"];

  Legend [shape=note, fontsize="11",
    label="STRIDE attack surface:\n- OpenAPI /docs (I)\n- SSRF via httpx (T, I)\n- Secrets via Settings (I)\n- Broken auth via Depends (S, E)"];
}"""


def render_architecture(filename: str | Path, *, fmt: str = "svg") -> Path:
    """Render the C4 Level 3 FastAPI component diagram."""
    return render_diagram(ARCHITECTURE_DOT, filename, fmt=fmt)
