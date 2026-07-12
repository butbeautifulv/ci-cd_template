#!/usr/bin/env python3
"""Generate threat modeling and architecture diagrams for Fabrica."""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path

from diagrams.architecture import render_architecture
from diagrams.dfd import render_dfd
from diagrams.k8s_deploy import render_k8s_deploy
from diagrams.pipeline import render_pipeline
from diagrams.requirements_export import export_requirements_yaml
from diagrams.stride_export import export_stride_md
from diagrams.threat_dragon_export import export_threat_dragon_json

log = logging.getLogger(__name__)

DIAGRAMS = {
    "dfd": ("dfd_diagram", render_dfd),
    "arch": ("architecture", render_architecture),
    "pipeline": ("pipeline_security", render_pipeline),
    "k8s": ("k8s_deploy", render_k8s_deploy),
}

EXPORTERS = {
    "stride-md": ("stride_register.md", export_stride_md),
    "threat-dragon": ("threat_model.json", export_threat_dragon_json),
    "requirements": ("security_requirements.yaml", export_requirements_yaml),
}


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Render Fabrica threat modeling diagrams and export TM artifacts."
    )
    parser.add_argument(
        "--output-dir",
        "-o",
        type=Path,
        default=Path("."),
        help="Directory for generated files (default: current directory)",
    )
    parser.add_argument(
        "--only",
        choices=["dfd", "arch", "pipeline", "k8s", "all"],
        default="all",
        help="Which diagram(s) to render (default: all)",
    )
    parser.add_argument(
        "--format",
        choices=["svg", "png"],
        default="svg",
        help="Output format (default: svg)",
    )
    parser.add_argument(
        "--export",
        choices=["stride-md", "threat-dragon", "requirements", "all"],
        help="Export threat modeling artifacts (optional)",
    )
    return parser.parse_args(argv)


def render_diagrams(args: argparse.Namespace) -> None:
    keys = list(DIAGRAMS) if args.only == "all" else [args.only]
    for key in keys:
        basename, render_fn = DIAGRAMS[key]
        out = args.output_dir / basename
        path = render_fn(out, fmt=args.format)
        log.info("Diagram successfully written to %s", path)


def export_artifacts(args: argparse.Namespace) -> None:
    keys = list(EXPORTERS) if args.export == "all" else [args.export]
    for key in keys:
        filename, export_fn = EXPORTERS[key]
        path = export_fn(args.output_dir / filename)
        log.info("Artifact successfully written to %s", path)


def main(argv: list[str] | None = None) -> int:
    logging.basicConfig(level=logging.INFO, format="%(message)s")
    args = parse_args(argv)
    args.output_dir.mkdir(parents=True, exist_ok=True)

    if args.export:
        if args.export == "all":
            render_diagrams(args)
        export_artifacts(args)
    else:
        render_diagrams(args)

    return 0


if __name__ == "__main__":
    sys.exit(main())
