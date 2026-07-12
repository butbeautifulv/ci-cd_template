"""CI/CD security gates overlay for DevSecOps education."""

from __future__ import annotations

from pathlib import Path

from diagrams.render import render_diagram

PIPELINE_DOT = r"""digraph PipelineSecurity {
  graph [
    rankdir="LR",
    fontname="DejaVu Sans",
    fontnames="svg",
    nodesep="0.6",
    ranksep="1.0",
    splines="polyline",
    labelloc="t",
    fontsize="14",
    label="DevSecOps Pipeline Security Overlay\nFabrica shift-left → runtime (reference)"
  ];
  node [fontname="DejaVu Sans", fontsize="11", shape=box, style="rounded,filled", fillcolor="white"];
  edge [fontname="DejaVu Sans", fontsize="10"];

  IDE       [label="IDE / pre-commit\nlocal hooks", fillcolor="lightyellow"];
  MR        [label="MR / PR pipeline\nB1 secrets, B2 SAST\nB3 OSA, B4 IaC, B5 Dockerfile", fillcolor="lightblue"];
  Build     [label="main build\nC1 SBOM, C2 SCA (image)\nC4 signing (opt)", fillcolor="palegreen"];
  Preprod   [label="preprod deploy\nD1 DAST / API fuzz\nD2 sec-func-tests", fillcolor="orange"];
  Prod      [label="prod runtime\nE1 admission, E2 network\nE3 Falco; F2 WAF/RASP (runbook)", fillcolor="lightcoral"];

  App       [label="FastAPI app\n(architecture.svg)", shape=component, fillcolor="khaki"];

  IDE -> MR       [label="push / MR"];
  MR -> Build     [label="merge main"];
  Build -> Preprod [label="deploy preprod"];
  Preprod -> Prod [label="promote prod"];

  MR -> App       [label="scans source", style="dashed", color="blue"];
  Build -> App    [label="scans image", style="dashed", color="green"];
  Preprod -> App  [label="DAST / IAST", style="dashed", color="orange"];
  Prod -> App     [label="admission + runtime", style="dashed", color="red"];

  Legend [shape=note, fontsize="10",
    label="Jobs: templates/gitlab/jobs/*\nPolicy: config/security-gate-policy.yaml\nASTO: scripts/aspm-export.py\nSTRIDE: shift-left trust boundary (runner != prod)"];
}"""


def render_pipeline(filename: str | Path, *, fmt: str = "svg") -> Path:
    """Render the CI/CD security pipeline overlay diagram."""
    return render_diagram(PIPELINE_DOT, filename, fmt=fmt)
