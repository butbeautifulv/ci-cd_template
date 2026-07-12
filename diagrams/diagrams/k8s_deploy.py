"""C4 Level 2 Kubernetes deployment diagram."""

from __future__ import annotations

from pathlib import Path

from diagrams.render import render_diagram

K8S_DEPLOY_DOT = r"""digraph K8sDeploy {
  graph [
    rankdir="TB",
    fontname="DejaVu Sans",
    fontnames="svg",
    nodesep="0.5",
    ranksep="0.8",
    splines="polyline",
    labelloc="t",
    fontsize="14",
    label="C4 Level 2: FastAPI Deployment on Kubernetes\nRuntime trust boundaries (Fabrica E-phase)"
  ];
  node [fontname="DejaVu Sans", fontsize="11"];
  edge [fontname="DejaVu Sans", fontsize="10"];

  User [label="User / Client", shape=rectangle];

  subgraph cluster_edge {
    label="Cluster Edge Trust Boundary";
    style="dashed";
    color="gray50";
    margin="8";

    Ingress [label="Ingress / WAF\nTLS termination\n(F2 runbook)", shape=box, style=filled, fillcolor="lightcoral"];
  }

  subgraph cluster_ns {
    label="Namespace: app (NetworkPolicy E2)";
    style="rounded";
    color="lightblue";
    margin="8";

    Service [label="Service: api\nClusterIP", shape=box, style=filled, fillcolor="lightblue"];
    Pod     [label="Deployment: api\nContainer: uvicorn + FastAPI\nseccomp, non-root (B5/E1)", shape=box3d, style=filled, fillcolor="palegreen"];
    Falco   [label="Runtime monitor\nFalco / CWPP (E3)", shape=note, fillcolor="lightyellow"];
  }

  subgraph cluster_data {
    label="External Data Plane";
    style="dashed";
    color="gray50";
    margin="8";

    PostgreSQL [label="PostgreSQL\nmanaged / in-cluster", shape=cylinder, style=filled, fillcolor="gainsboro"];
    S3         [label="S3 object storage", shape=cylinder, style=filled, fillcolor="lightgray"];
  }

  User -> Ingress           [label="HTTPS/TLS 1.3"];
  Ingress -> Service        [label="L7 route"];
  Service -> Pod            [label="port 8000"];
  Pod -> PostgreSQL         [label="asyncpg / TLS"];
  Pod -> S3                 [label="S3 API / HTTPS"];
  Falco -> Pod              [label="syscall / exec alerts", style="dotted", color="red"];

  Legend [shape=note, fontsize="10",
    label="Controls:\nE1 Kyverno/OPA admission\nE2 NetworkPolicy\nE3 Falco runtime\nJCSF: orchr, cont, gen"];
}"""


def render_k8s_deploy(filename: str | Path, *, fmt: str = "svg") -> Path:
    """Render the Kubernetes deployment diagram."""
    return render_diagram(K8S_DEPLOY_DOT, filename, fmt=fmt)
