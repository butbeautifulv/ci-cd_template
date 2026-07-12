"""Export security requirements traceable to STRIDE threats and Fabrica controls."""

from __future__ import annotations

import json
from pathlib import Path

from diagrams.stride_export import iter_threats

DOMAIN_BY_STRIDE: dict[str, str] = {
    "Spoofing": "authentication",
    "Tampering": "input_validation",
    "Repudiation": "audit_logging",
    "Information Disclosure": "data_protection",
    "Denial of Service": "availability",
    "Elevation of Privilege": "authorization",
}

REQUIREMENT_TEXT: dict[str, str] = {
    "Spoofing": "Validate identity tokens and reject missing or expired credentials",
    "Tampering": "Validate and sanitize all inputs; use parameterized queries",
    "Repudiation": "Log security-relevant actions with tamper-evident storage",
    "Information Disclosure": "Encrypt sensitive data; enforce least-privilege access",
    "Denial of Service": "Apply rate limiting and resource quotas on public endpoints",
    "Elevation of Privilege": "Enforce authorization on every protected route and resource",
}

TESTABILITY: dict[str, str] = {
    "authentication": "sec-func-tests: expired token → 401",
    "input_validation": "SAST/DAST: injection payloads blocked",
    "audit_logging": "Verify audit events for auth and admin actions",
    "data_protection": "B1 secret-scan; no secrets in logs or /docs",
    "availability": "Load test within SLO; rate limit returns 429",
    "authorization": "sec-func-tests: forbidden role → 403",
}


def _requirements() -> list[dict]:
    items: list[dict] = []
    for idx, threat in enumerate(iter_threats(), start=1):
        domain = DOMAIN_BY_STRIDE.get(threat["stride"], "general")
        fabrica = [
            part.strip()
            for part in threat["fabrica_control"].split(",")
            if part.strip() and part.strip() != "—"
        ]
        items.append(
            {
                "id": f"SR-{idx:03d}",
                "threat_ref": threat["id"],
                "domain": domain,
                "requirement": REQUIREMENT_TEXT.get(
                    threat["stride"], "Review and document security control"
                ),
                "fabrica_control": fabrica,
                "testability": TESTABILITY.get(domain, "Manual design review"),
            }
        )
    return items


def export_requirements_yaml(output_path: str | Path) -> Path:
    """Write security_requirements.yaml without PyYAML dependency."""
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = ["requirements:"]
    for item in _requirements():
        lines.append(f"  - id: {item['id']}")
        lines.append(f"    threat_ref: {item['threat_ref']}")
        lines.append(f"    domain: {item['domain']}")
        lines.append(f'    requirement: "{item["requirement"]}"')
        controls = ", ".join(item["fabrica_control"]) or "—"
        lines.append(f"    fabrica_control: [{controls}]")
        lines.append(f'    testability: "{item["testability"]}"')
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return path


def export_requirements_json(output_path: str | Path) -> Path:
    """Write security_requirements.json."""
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps({"requirements": _requirements()}, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    return path
