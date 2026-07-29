#!/usr/bin/env python3
"""Poll source repos; create mirror API pipelines when SHA changes.

State file: .mirror-sync-state.json  { service: {sha, updated_at} }

Env:
  GITLAB_PAT / SOURCE_GIT_TOKEN
  MIRROR_PROJECT_ID
  MIRROR_SERVICES (path)
  GITLAB_URL / CI_API_V4_URL
  MIRROR_PIPELINE_REF (default main)
  MIRROR_SYNC_DRY_RUN=1
  SOURCE_SSL_NO_VERIFY=1
"""
from __future__ import annotations

import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


def api_base() -> str:
    base = os.environ.get("CI_API_V4_URL") or os.environ.get("GITLAB_URL") or "https://gitlab.svo.aero"
    base = base.rstrip("/")
    if not base.endswith("/api/v4"):
        base = f"{base}/api/v4"
    return base


def token() -> str:
    for k in ("GITLAB_PAT", "SOURCE_GIT_TOKEN", "PRIVATE_TOKEN", "CI_JOB_TOKEN"):
        v = os.environ.get(k)
        if v:
            return v
    raise SystemExit("ERROR: GITLAB_PAT or SOURCE_GIT_TOKEN required")


def ssl_ctx() -> ssl.SSLContext:
    ctx = ssl.create_default_context()
    if os.environ.get("SOURCE_SSL_NO_VERIFY", "1") in ("1", "true", "TRUE"):
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
    return ctx


def http_json(method: str, url: str, tok: str, ctx: ssl.SSLContext, body: dict | None = None):
    data = None
    headers = {"PRIVATE-TOKEN": tok, "Content-Type": "application/json"}
    if body is not None:
        data = json.dumps(body).encode()
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, context=ctx, timeout=60) as resp:
        return json.load(resp)


def parse_services(path: Path) -> list[dict]:
    text = path.read_text(encoding="utf-8")
    services: list[dict] = []
    name = None
    cur: dict = {}
    in_svc = False
    for line in text.splitlines():
        if line.startswith("services:"):
            continue
        if line.startswith("  ") and line.rstrip().endswith(":") and not line.strip().startswith("#"):
            key = line.strip().rstrip(":")
            if not key.startswith("#") and ":" not in key.replace(key, ""):
                # service name line: "  hwa_service:"
                if name and cur.get("project_id"):
                    services.append({"name": name, **cur})
                name = key
                cur = {}
                in_svc = True
                continue
        if not in_svc or name is None:
            continue
        if line.startswith("    ") and ":" in line and not line.strip().startswith("#"):
            k, _, v = line.strip().partition(":")
            v = v.strip().strip("\"'")
            if k in ("project_id", "repo_url", "source_ref_fallback", "openapi_path", "api_base_url"):
                cur[k] = v
        if line and not line.startswith(" ") and not line.startswith("#"):
            if name and cur.get("project_id"):
                services.append({"name": name, **cur})
            in_svc = False
            name = None
            cur = {}
    if name and cur.get("project_id"):
        services.append({"name": name, **cur})
    return services


def latest_commit_sha(project_id: str, ref: str, tok: str, ctx: ssl.SSLContext) -> str:
    enc = urllib.parse.quote(ref, safe="")
    url = f"{api_base()}/projects/{project_id}/repository/commits?ref_name={enc}&per_page=1"
    data = http_json("GET", url, tok, ctx)
    if isinstance(data, list) and data:
        return str(data[0].get("id") or "")
    return ""


def running_pipeline_exists(
    mirror_id: str, service: str, sha: str, tok: str, ctx: ssl.SSLContext
) -> bool:
    """Dedupe: any running/pending pipeline with matching SERVICE_NAME + SOURCE_REF vars."""
    url = f"{api_base()}/projects/{mirror_id}/pipelines?status=running&per_page=50"
    try:
        pipes = http_json("GET", url, tok, ctx)
    except urllib.error.HTTPError:
        return False
    if not isinstance(pipes, list):
        return False
    for p in pipes:
        pid = p.get("id")
        if not pid:
            continue
        try:
            vars_url = f"{api_base()}/projects/{mirror_id}/pipelines/{pid}/variables"
            variables = http_json("GET", vars_url, tok, ctx)
        except urllib.error.HTTPError:
            continue
        if not isinstance(variables, list):
            continue
        kv = {v.get("key"): v.get("value") for v in variables if isinstance(v, dict)}
        if kv.get("SERVICE_NAME") == service and kv.get("SOURCE_REF") == sha:
            print(f"[sync] dedupe: pipeline {pid} already running for {service}@{sha}")
            return True
    # also pending
    url = f"{api_base()}/projects/{mirror_id}/pipelines?status=pending&per_page=50"
    try:
        pipes = http_json("GET", url, tok, ctx)
    except urllib.error.HTTPError:
        return False
    if not isinstance(pipes, list):
        return False
    for p in pipes:
        pid = p.get("id")
        if not pid:
            continue
        try:
            vars_url = f"{api_base()}/projects/{mirror_id}/pipelines/{pid}/variables"
            variables = http_json("GET", vars_url, tok, ctx)
        except urllib.error.HTTPError:
            continue
        if not isinstance(variables, list):
            continue
        kv = {v.get("key"): v.get("value") for v in variables if isinstance(v, dict)}
        if kv.get("SERVICE_NAME") == service and kv.get("SOURCE_REF") == sha:
            print(f"[sync] dedupe: pipeline {pid} pending for {service}@{sha}")
            return True
    return False


def create_pipeline(
    mirror_id: str, ref: str, service: str, sha: str, tok: str, ctx: ssl.SSLContext
) -> dict:
    body = {
        "ref": ref,
        "variables": [
            {"key": "SERVICE_NAME", "value": service},
            {"key": "SOURCE_REF", "value": sha},
        ],
    }
    url = f"{api_base()}/projects/{mirror_id}/pipeline"
    return http_json("POST", url, tok, ctx, body)


def main() -> int:
    reg = Path(os.environ.get("MIRROR_SERVICES", "config/mirror-services.yaml"))
    state_path = Path(os.environ.get("MIRROR_SYNC_STATE", ".mirror-sync-state.json"))
    mirror_id = os.environ.get("MIRROR_PROJECT_ID") or os.environ.get("CI_PROJECT_ID")
    if not mirror_id:
        print("ERROR: MIRROR_PROJECT_ID required", file=sys.stderr)
        return 1
    if not reg.is_file():
        print(f"ERROR: missing {reg}", file=sys.stderr)
        return 1

    dry = os.environ.get("MIRROR_SYNC_DRY_RUN", "") in ("1", "true", "TRUE")
    pipe_ref = os.environ.get("MIRROR_PIPELINE_REF", "main")
    tok = token()
    ctx = ssl_ctx()
    services = parse_services(reg)
    state: dict = {}
    if state_path.is_file():
        try:
            state = json.loads(state_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            state = {}

    created = 0
    for svc in services:
        name = svc["name"]
        pid = svc["project_id"]
        ref = svc.get("source_ref_fallback") or "main"
        try:
            sha = latest_commit_sha(pid, ref, tok, ctx)
        except urllib.error.HTTPError as e:
            print(f"[sync] WARN: {name} commits@{ref}: {e}")
            continue
        if not sha:
            print(f"[sync] WARN: {name} empty SHA for ref={ref}")
            continue
        prev = (state.get(name) or {}).get("sha")
        if prev == sha:
            print(f"[sync] {name} unchanged {sha[:12]}")
            continue
        print(f"[sync] {name} changed {prev or '∅'} → {sha[:12]}")
        if running_pipeline_exists(str(mirror_id), name, sha, tok, ctx):
            state[name] = {"sha": sha, "updated_at": datetime.now(timezone.utc).isoformat()}
            continue
        if dry:
            print(f"[sync] dry-run would create pipeline SERVICE_NAME={name} SOURCE_REF={sha}")
            state[name] = {"sha": sha, "updated_at": datetime.now(timezone.utc).isoformat()}
            continue
        try:
            p = create_pipeline(str(mirror_id), pipe_ref, name, sha, tok, ctx)
            print(f"[sync] pipeline id={p.get('id')} url={p.get('web_url')}")
            created += 1
            time.sleep(2)
        except urllib.error.HTTPError as e:
            print(f"[sync] ERROR create pipeline {name}: {e}")
            continue
        state[name] = {"sha": sha, "updated_at": datetime.now(timezone.utc).isoformat()}

    state_path.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
    print(f"[sync] done created={created} state={state_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
