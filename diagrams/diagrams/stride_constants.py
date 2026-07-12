"""STRIDE categories and mitigations (adapted from OWASP Threat Dragon agent)."""

from __future__ import annotations

STRIDE_BY_ELEMENT: dict[str, list[str]] = {
    "process": [
        "Spoofing",
        "Tampering",
        "Repudiation",
        "Information Disclosure",
        "Denial of Service",
        "Elevation of Privilege",
    ],
    "data_store": [
        "Tampering",
        "Information Disclosure",
        "Denial of Service",
    ],
    "data_flow": [
        "Tampering",
        "Information Disclosure",
        "Denial of Service",
    ],
    "external_entity": [
        "Spoofing",
        "Repudiation",
    ],
}

STRIDE_MITIGATIONS: dict[str, list[str]] = {
    "Spoofing": [
        "Implement strong authentication (MFA)",
        "Use mutual TLS for service-to-service",
    ],
    "Tampering": [
        "Use integrity checks (HMAC, digital signatures)",
        "Implement input validation",
    ],
    "Repudiation": [
        "Enable comprehensive audit logging",
        "Use tamper-evident log storage",
    ],
    "Information Disclosure": [
        "Encrypt data at rest and in transit",
        "Implement least-privilege access",
    ],
    "Denial of Service": [
        "Implement rate limiting",
        "Use auto-scaling and circuit breakers",
    ],
    "Elevation of Privilege": [
        "Enforce RBAC and least privilege",
        "Validate authorization on every request",
    ],
}

STRIDE_ABBREV: dict[str, str] = {
    "Spoofing": "S",
    "Tampering": "T",
    "Repudiation": "R",
    "Information Disclosure": "I",
    "Denial of Service": "D",
    "Elevation of Privilege": "E",
}

# Workshop default when impact/likelihood not assessed
DEFAULT_RISK_LEVEL = "Medium"
