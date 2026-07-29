#!/usr/bin/env python3
from __future__ import annotations
import argparse, json, os, ssl, sys, urllib.error, urllib.parse, urllib.request

def ssl_ctx():
    if os.environ.get("DEFECTDOJO_INSECURE", "").lower() in ("1", "true", "yes"):
        return ssl._create_unverified_context()
    return None

def api(method, path, token, base, data=None):
    url = f"{base.rstrip('/')}{path}"
    req = urllib.request.Request(url, data=data, method=method, headers={"Authorization": f"Token {token}", "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60, context=ssl_ctx()) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            return resp.status, json.loads(body) if body.strip() else {}
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")[:500]
        return e.code, {"error": detail}

def list_all(base, token, path, params):
    results = []
    q = dict(params); q.setdefault("limit", "200"); offset = 0
    while True:
        q["offset"] = str(offset)
        code, payload = api("GET", f"{path}?{urllib.parse.urlencode(q)}", token, base)
        if code >= 400 or not isinstance(payload, dict):
            raise SystemExit(f"list failed {path}: {code} {payload}")
        chunk = payload.get("results") or []
        results.extend(chunk)
        if not payload.get("next") or not chunk:
            break
        offset += len(chunk)
    return results

def main():
    p = argparse.ArgumentParser(); p.add_argument("--product", required=True); p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()
    base = os.environ["DEFECTDOJO_URL"].rstrip("/")
    token = os.environ["DEFECTDOJO_API_TOKEN"]
    products = list_all(base, token, "/api/v2/products/", {"name": args.product})
    match = [x for x in products if x.get("name") == args.product] or [x for x in products if args.product in str(x.get("name",""))]
    if not match:
        print(f"[wipe] no product {args.product!r}"); return
    pid = match[0]["id"]
    print(f"[wipe] product id={pid} name={match[0].get('name')}")
    engagements = list_all(base, token, "/api/v2/engagements/", {"product": str(pid)})
    print(f"[wipe] engagements={len(engagements)}")
    for eng in engagements:
        eid = eng["id"]
        tests = list_all(base, token, "/api/v2/tests/", {"engagement": str(eid)})
        print(f"[wipe] engagement id={eid} name={eng.get('name')} tests={len(tests)}")
        for t in tests:
            tid = t["id"]; title = t.get("title") or t.get("test_type_name")
            if args.dry_run:
                print(f"  dry-run DELETE test id={tid} title={title}")
                continue
            code, payload = api("DELETE", f"/api/v2/tests/{tid}/", token, base)
            print(f"  deleted test id={tid} title={title} http={code} {payload if code>=400 else ''}")
        if args.dry_run:
            print(f"  dry-run DELETE engagement id={eid}")
            continue
        code, payload = api("DELETE", f"/api/v2/engagements/{eid}/", token, base)
        print(f"[wipe] DELETE engagement id={eid} http={code} {payload if code>=400 else ''}")
    # leftover tests by product via engagement filter already covered
    print("[wipe] done")

if __name__ == "__main__":
    main()
