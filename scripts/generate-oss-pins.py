#!/usr/bin/env python3
"""Generate OSS pin mirrors from config/oss-tool-versions.yaml (stdlib only)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = ROOT / "config" / "oss-tool-versions.yaml"
GITLAB_VERSIONS = ROOT / "templates" / "gitlab" / "jobs" / "oss" / "versions.yml"
GITHUB_ENV = ROOT / "config" / "github-oss-env.yml"
GITHUB_PROFILE = ROOT / "templates" / "profiles" / "oss-full.github.yml"

HEADER = "# GENERATED — do not edit. Run: python3 scripts/generate-oss-pins.py\n"


def parse_manifest(text: str) -> dict[str, dict[str, str]]:
    """Parse flat key: value blocks from oss-tool-versions.yaml."""
    sections: dict[str, dict[str, str]] = {}
    current: str | None = None
    for line in text.splitlines():
        if re.match(r"^[a-z_]+:\s*$", line):
            current = line.rstrip(":").strip()
            sections[current] = {}
            continue
        m = re.match(r'^\s{2}([a-z_]+):\s*"?([^"#\n]+)"?\s*$', line)
        if m and current:
            sections[current][m.group(1)] = m.group(2).strip().strip('"')
    required = ("images", "binaries", "pip", "github_actions")
    for sec in required:
        if sec not in sections or not sections[sec]:
            raise SystemExit(f"Missing section '{sec}' in {MANIFEST}")
    return sections


def syft_version_tag(syft_image: str) -> str:
    return syft_image.rsplit(":", 1)[-1] if ":" in syft_image else syft_image


def render_gitlab_versions(m: dict[str, dict[str, str]]) -> str:
    img, bin_, pip = m["images"], m["binaries"], m["pip"]
    lines = [
        HEADER.rstrip(),
        "# OSS tool pins — source: config/oss-tool-versions.yaml",
        "",
        "variables:",
        f'  OSS_SEMGREP_IMAGE: "{img["semgrep"]}"',
        f'  OSS_SYFT_IMAGE: "{img["syft"]}"',
        f'  OSS_HADOLINT_IMAGE: "{img["hadolint"]}"',
        f'  OSS_CONFTEST_IMAGE: "{img["conftest"]}"',
        f'  OSS_ZAPROXY_IMAGE: "{img["zaproxy"]}"',
        f'  OSS_CURL_IMAGE: "{img["curl"]}"',
        f'  OSS_HELM_IMAGE: "{img["helm"]}"',
        f'  OSS_KUBECTL_VERSION: "{img["kubectl"]}"',
        f'  OSS_PYTHON_IMAGE: "{img["python"]}"',
        f'  OSS_DOCKER_CLI_IMAGE: "{img["docker_cli"]}"',
        f'  OSS_DOCKER_DIND_IMAGE: "{img["docker_dind"]}"',
        f'  OSS_TRIVY_VERSION: "{bin_["trivy"]}"',
        f'  OSS_GITLEAKS_VERSION: "{bin_["gitleaks"]}"',
        f'  OSS_CHECKOV_VERSION: "{pip["checkov"]}"',
        f'  OSS_RUFF_VERSION: "{pip["ruff"]}"',
        "",
    ]
    return "\n".join(lines)


def render_github_env(m: dict[str, dict[str, str]]) -> str:
    img, bin_, pip, ga = m["images"], m["binaries"], m["pip"], m["github_actions"]
    lines = [
        HEADER.rstrip(),
        "# GitHub OSS env — source: config/oss-tool-versions.yaml",
        "# Used by profile oss-full and security-gates-oss workflows",
        "",
        "REGISTRY_BACKEND: gitlab",
        'ENABLE_REAL_LINTERS: "true"',
        "SECURITY_POLICY: config/security-gate-policy.yaml",
        "",
        f'OSS_SEMGREP_IMAGE: {img["semgrep"]}',
        f'OSS_SYFT_VERSION: {syft_version_tag(img["syft"])}',
        f'OSS_HADOLINT_IMAGE: {img["hadolint"]}',
        f'OSS_TRIVY_VERSION: "{bin_["trivy"]}"',
        f'OSS_GITLEAKS_VERSION: "{bin_["gitleaks"]}"',
        f'OSS_CHECKOV_VERSION: "{pip["checkov"]}"',
        f'OSS_RUFF_VERSION: "{pip["ruff"]}"',
        f'OSS_ZAPROXY_IMAGE: {img["zaproxy"]}',
        "",
        f"ACTIONS_CHECKOUT: {ga['checkout']}",
        f"ACTIONS_UPLOAD_SARIF: {ga['upload_sarif']}",
        f"ACTIONS_UPLOAD_ARTIFACT: {ga['upload_artifact']}",
        f"ACTIONS_LOGIN_GHCR: {ga['login_ghcr']}",
        f"ACTIONS_BUILD_PUSH: {ga['build_push']}",
        f"COSIGN_INSTALLER_VERSION: {ga['cosign_installer']}",
        "",
    ]
    return "\n".join(lines)


def render_github_profile_env(m: dict[str, dict[str, str]]) -> str:
    img, bin_, pip = m["images"], m["binaries"], m["pip"]
    lines = [
        "env:",
        "  REGISTRY: ghcr.io/${{ github.repository }}",
        "  CI_REGISTRY_IMAGE: ghcr.io/${{ github.repository }}",
        "  REGISTRY_BACKEND: gitlab",
        '  ENABLE_REAL_LINTERS: "true"',
        "  SECURITY_POLICY: config/security-gate-policy.yaml",
        f'  OSS_SEMGREP_IMAGE: {img["semgrep"]}',
        f'  OSS_SYFT_VERSION: {syft_version_tag(img["syft"])}',
        f'  OSS_HADOLINT_IMAGE: {img["hadolint"]}',
        f'  OSS_TRIVY_VERSION: "{bin_["trivy"]}"',
        f'  OSS_GITLEAKS_VERSION: "{bin_["gitleaks"]}"',
        f'  OSS_CHECKOV_VERSION: "{pip["checkov"]}"',
        f'  OSS_RUFF_VERSION: "{pip["ruff"]}"',
        "",
    ]
    return "\n".join(lines)


def patch_github_profile(m: dict[str, dict[str, str]]) -> None:
    text = GITHUB_PROFILE.read_text(encoding="utf-8")
    new_env = render_github_profile_env(m)
    patched, n = re.subn(
        r"^env:\n(?:  .+\n)+",
        new_env,
        text,
        count=1,
        flags=re.MULTILINE,
    )
    if n != 1:
        raise SystemExit(f"Could not patch env block in {GITHUB_PROFILE}")
    GITHUB_PROFILE.write_text(patched, encoding="utf-8")


def main() -> int:
    m = parse_manifest(MANIFEST.read_text(encoding="utf-8"))
    GITLAB_VERSIONS.write_text(render_gitlab_versions(m), encoding="utf-8")
    GITHUB_ENV.write_text(render_github_env(m), encoding="utf-8")
    patch_github_profile(m)
    print(f"Generated: {GITLAB_VERSIONS.relative_to(ROOT)}")
    print(f"Generated: {GITHUB_ENV.relative_to(ROOT)}")
    print(f"Patched:   {GITHUB_PROFILE.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
