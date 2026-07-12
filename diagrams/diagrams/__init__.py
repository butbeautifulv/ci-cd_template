"""Threat modeling and architecture diagram generators for Fabrica."""

from diagrams.architecture import render_architecture
from diagrams.dfd import build_dfd_dot, render_dfd
from diagrams.k8s_deploy import render_k8s_deploy
from diagrams.model import FASTAPI_DFD_ELEMENTS, FASTAPI_DFD_FLOWS
from diagrams.pipeline import render_pipeline
from diagrams.render import ensure_output_path, render_diagram
from diagrams.requirements_export import export_requirements_json, export_requirements_yaml
from diagrams.stride_export import export_stride_md, iter_threats
from diagrams.threat_dragon_export import export_threat_dragon_json

__all__ = [
    "FASTAPI_DFD_ELEMENTS",
    "FASTAPI_DFD_FLOWS",
    "build_dfd_dot",
    "ensure_output_path",
    "export_requirements_json",
    "export_requirements_yaml",
    "export_stride_md",
    "export_threat_dragon_json",
    "iter_threats",
    "render_architecture",
    "render_dfd",
    "render_diagram",
    "render_k8s_deploy",
    "render_pipeline",
]
