#!/usr/bin/env python3
"""List GitLab projects under dpm/.../map_objects (+ optional airport siblings).

Env:
  GITLAB_URL or CI_API_V4_URL  (default https://gitlab.svo.aero)
  GITLAB_PAT / SOURCE_GIT_TOKEN / PRIVATE_TOKEN
  MIRROR_INVENTORY_GROUP   default: dpm/airport_digital_ecosystem/map_objects
  MIRROR_INVENTORY_SIBLINGS  default: 1 — also list sibling projects under parent group

Output: TSV to stdout: path\\tproject_id\\thttp_url\\tdefault_branch\\tlatest_tag
Optional: --yaml-stub → print YAML fragment for mirror-services.yaml
"""
from __future__ import annotations

import argparse
import json
import os
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request


def api_base() -> str:
    base = os.environ.get("CI_API_V4_URL") or os.environ.get("GITLAB_URL") or "https://gitlab.svo.aero"
    base = base.rstrip("/")
    if not base.endswith("/api/v4"):
        base = f"{base}/api/v4"
    return base


def token() -> str:
    for k in ("GITLAB_PAT", "SOURCE_GIT_TOKEN", "PRIVATE_TOKEN", "GITLAB_PAT_RUNNER"):
        v = os.environ.get(k)
        if v:
            return v
    raise SystemExit("ERROR: set GITLAB_PAT or SOURCE_GIT_TOKEN")


def http_json(url: str, tok: str, ctx: ssl.SSLContext) -> object:
    req = urllib.request.Request(url, headers={"PRIVATE-TOKEN": tok})
    with urllib.request.urlopen(req, context=ctx, timeout=60) as resp:
        return json.load(resp)


def paginate(path: str, tok: str, ctx: ssl.SSLContext, params: dict | None = None) -> list:
    base = api_base()
    page = 1
    out: list = []
    while True:
        q = dict(params or {})
        q.update({"per_page": 100, "page": page})
        url = f"{base}{path}?{urllib.parse.urlencode(q)}"
        chunk = http_json(url, tok, ctx)
        if not isinstance(chunk, list) or not chunk:
            break
        out.extend(chunk)
        if len(chunk) < 100:
            break
        page += 1
    return out


def latest_tag(project_id: int, tok: str, ctx: ssl.SSLContext) -> str:
    try:
        tags = http_json(
            f"{api_base()}/projects/{project_id}/repository/tags?per_page=20",
            tok,
            ctx,
        )
    except urllib.error.HTTPError:
        return ""
    if not isinstance(tags, list) or not tags:
        return ""
    # Prefer semver-ish v* / x.y.z
    for t in tags:
        name = t.get("name") or ""
        if name.startswith("v") or (name[:1].isdigit() and "." in name):
            return name
    return tags[0].get("name") or ""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--yaml-stub", action="store_true")
    ap.add_argument(
        "--group",
        default=os.environ.get(
            "MIRROR_INVENTORY_GROUP", "dpm/airport_digital_ecosystem/map_objects"
        ),
    )
    args = ap.parse_args()
    tok = token()
    ctx = ssl.create_default_context()
    if os.environ.get("SOURCE_SSL_NO_VERIFY", "1") in ("1", "true", "TRUE"):
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE

    group_enc = urllib.parse.quote(args.group, safe="")
    try:
        projects = paginate(
            f"/groups/{group_enc}/projects",
            tok,
            ctx,
            {"include_subgroups": "true", "archived": "false", "simple": "true"},
        )
    except urllib.error.HTTPError as e:
        print(f"ERROR: group projects {args.group}: {e}", file=sys.stderr)
        return 1

    # Optional siblings under parent group (airport_digital_ecosystem)
    if os.environ.get("MIRROR_INVENTORY_SIBLINGS", "1") in ("1", "true", "TRUE"):
        parent = args.group.rsplit("/", 1)[0]
        if parent and parent != args.group:
            penc = urllib.parse.quote(parent, safe="")
            try:
                more = paginate(
                    f"/groups/{penc}/projects",
                    tok,
                    ctx,
                    {"include_subgroups": "false", "archived": "false", "simple": "true"},
                )
                seen = {p.get("id") for p in projects}
                for p in more:
                    if p.get("id") not in seen:
                        projects.append(p)
            except urllib.error.HTTPError:
                pass

    rows = []
    for p in sorted(projects, key=lambda x: x.get("path_with_namespace") or ""):
        pid = p.get("id")
        path = p.get("path_with_namespace") or p.get("path") or ""
        url = p.get("http_url_to_repo") or ""
        branch = p.get("default_branch") or "main"
        tag = latest_tag(int(pid), tok, ctx) if pid else ""
        rows.append((path, str(pid), url, branch, tag))

    if args.yaml_stub:
        print("# Generated stub — review before commit to config/mirror-services.yaml")
        print("services:")
        for path, pid, url, branch, tag in rows:
            name = path.rsplit("/", 1)[-1]
            fb = tag or branch
            # strip leading v for fallback style used today
            if fb.startswith("v") and fb[1:2].isdigit():
                fb_out = fb[1:]
            else:
                fb_out = fb
            print(f"  {name}:")
            print(f'    project_id: "{pid}"')
            print(f'    repo_url: "{url}"')
            print(f'    source_ref_fallback: "{fb_out}"')
            print("    enabled: false")
            print("    tier: candidate")
            print('    # openapi_path: ""')
            print('    # api_base_url: ""')
        return 0

    print("path\tproject_id\thttp_url\tdefault_branch\tlatest_tag")
    for r in rows:
        print("\t".join(r))
    print(f"# count={len(rows)}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
