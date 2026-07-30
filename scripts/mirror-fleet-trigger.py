#!/usr/bin/env python3
"""Create map_objects-ci pipelines for curated mirror-services.yaml entries.

  GITLAB_PAT=… MIRROR_PROJECT_ID=1962 \\
    python3 scripts/mirror-fleet-trigger.py --dry-run
  python3 scripts/mirror-fleet-trigger.py --services a,b --concurrency 1

No git tags. Variables: SERVICE_NAME, SOURCE_REF (= source_ref_fallback).
"""
from __future__ import annotations

import argparse
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

from lib.mirror_services import filter_services, load_services  # noqa: E402

# Wave-3 pilots (deploy-capable). Keep --wave6 as alias for scripts/Make.
WAVE3 = [
    "hwa_service",
    "data_lake_service",
    "user_service",
]
WAVE6 = WAVE3  # backwards-compat alias


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
    raise SystemExit("ERROR: GITLAB_PAT required (unless --dry-run)")


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


def detect_ref(api: str, tok: str, project_id: str, ctx: ssl.SSLContext, explicit: str) -> str:
    if explicit:
        return explicit
    env_ref = os.environ.get("MIRROR_PIPELINE_REF", "")
    if env_ref:
        return env_ref
    try:
        p = http_json("GET", f"{api}/projects/{project_id}", tok, ctx)
        return str(p.get("default_branch") or "main")
    except urllib.error.HTTPError:
        return "main"


def main() -> int:
    ap = argparse.ArgumentParser(description="Mirror fleet pipeline trigger")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--ref", default="", help="Pipeline git ref on mirror (default: project default_branch)")
    ap.add_argument("--tier", default="", help="pilot|core|candidate|skip|all (empty = no tier filter)")
    ap.add_argument("--concurrency", type=int, default=1, help="Max in-flight creates; sleep between POSTs")
    ap.add_argument("--sleep", type=float, default=2.0, help="Seconds between pipeline creates")
    ap.add_argument("--services", default="", help="Comma-separated allow-list (default: all matching filters)")
    ap.add_argument("--enabled-only", action=argparse.BooleanOptionalAction, default=True)
    ap.add_argument(
        "--wave3",
        action="store_true",
        help="Shorthand: Wave-3 pilot allow-list (hwa, data_lake, user)",
    )
    ap.add_argument(
        "--wave6",
        action="store_true",
        help="Alias for --wave3 (legacy name)",
    )
    ap.add_argument(
        "--registry",
        default=os.environ.get("MIRROR_SERVICES", str(ROOT / "config" / "mirror-services.yaml")),
    )
    ap.add_argument(
        "--jsonl",
        default=str(ROOT / "reports" / "mirror-fleet-last.jsonl"),
        help="Append live create results here",
    )
    args = ap.parse_args()

    reg = Path(args.registry)
    if not reg.is_file():
        print(f"ERROR: missing {reg}", file=sys.stderr)
        return 1

    names = None
    if args.wave3 or args.wave6:
        names = list(WAVE3)
    elif args.services.strip():
        names = [x.strip() for x in args.services.split(",") if x.strip()]

    tier = args.tier.strip() or None
    svcs = filter_services(
        load_services(reg),
        tier=tier,
        enabled_only=args.enabled_only,
        names=names,
    )
    if not svcs:
        print("[fleet] no services matched filters", file=sys.stderr)
        return 1

    for s in svcs:
        sref = s.get("source_ref_fallback") or ""
        print(f"[fleet] SERVICE_NAME={s['name']} SOURCE_REF={sref} tier={s.get('tier')} enabled={s.get('enabled')}")

    if args.dry_run:
        print(f"[fleet] dry-run count={len(svcs)}")
        return 0

    tok = token()
    project_id = os.environ.get("MIRROR_PROJECT_ID") or os.environ.get("CI_PROJECT_ID")
    if not project_id:
        print("ERROR: MIRROR_PROJECT_ID required", file=sys.stderr)
        return 1

    api = api_base()
    ctx = ssl_ctx()
    ref = detect_ref(api, tok, str(project_id), ctx, args.ref)
    jsonl_path = Path(args.jsonl)
    jsonl_path.parent.mkdir(parents=True, exist_ok=True)

    failed = 0
    created = 0
    # concurrency>1 still serializes POSTs with sleep; cap documented as in-flight creates pacing
    conc = max(1, int(args.concurrency))
    _ = conc  # reserved for future parallel wait; pacing via sleep

    for s in svcs:
        name = s["name"]
        sref = s.get("source_ref_fallback") or ""
        if not sref:
            print(f"[fleet] SKIP {name}: empty source_ref_fallback")
            failed += 1
            continue
        body = {
            "ref": ref,
            "variables": [
                {"key": "SERVICE_NAME", "value": name},
                {"key": "SOURCE_REF", "value": sref},
            ],
        }
        try:
            p = http_json("POST", f"{api}/projects/{project_id}/pipeline", tok, ctx, body)
            row = {
                "ts": datetime.now(timezone.utc).isoformat(),
                "service": name,
                "source_ref": sref,
                "pipeline_id": p.get("id"),
                "status": p.get("status"),
                "web_url": p.get("web_url"),
            }
            print(f"  pipeline id={row['pipeline_id']} status={row['status']} url={row['web_url']}")
            with jsonl_path.open("a", encoding="utf-8") as fh:
                fh.write(json.dumps(row, ensure_ascii=False) + "\n")
            created += 1
        except urllib.error.HTTPError as e:
            print(f"[fleet] ERROR {name}: {e}", file=sys.stderr)
            failed += 1
            with jsonl_path.open("a", encoding="utf-8") as fh:
                fh.write(
                    json.dumps(
                        {
                            "ts": datetime.now(timezone.utc).isoformat(),
                            "service": name,
                            "source_ref": sref,
                            "error": str(e),
                        },
                        ensure_ascii=False,
                    )
                    + "\n"
                )
        time.sleep(max(0.0, float(args.sleep)))

    print(f"[fleet] done created={created} failed={failed} jsonl={jsonl_path}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
