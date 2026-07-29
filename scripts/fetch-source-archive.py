#!/usr/bin/env python3
"""Fetch a GitLab project archive into dest (corp offline; no apt/apk).

Usage:
  fetch-source-archive.py <api_v4_url> <project_id> <ref> <dest> <token>
Env:
  SOURCE_SSL_NO_VERIFY=1  — disable TLS verify (corp MITM)
"""
from __future__ import annotations

import io
import os
import ssl
import sys
import tarfile
import urllib.error
import urllib.parse
import urllib.request


def main() -> int:
    if len(sys.argv) != 6:
        print(
            "usage: fetch-source-archive.py <api> <project_id> <ref> <dest> <token>",
            file=sys.stderr,
        )
        return 2
    api, pid, ref, dest, token = sys.argv[1:6]
    url = f"{api}/projects/{pid}/repository/archive.tar.gz?sha={urllib.parse.quote(ref)}"
    ctx = ssl.create_default_context()
    if os.environ.get("SOURCE_SSL_NO_VERIFY", "").lower() in ("1", "true", "yes"):
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
    req = urllib.request.Request(url, headers={"PRIVATE-TOKEN": token})
    try:
        with urllib.request.urlopen(req, context=ctx, timeout=120) as resp:
            data = resp.read()
    except urllib.error.HTTPError as e:
        raise SystemExit(f"archive HTTP {e.code}: {e.read()[:200]!r}") from e
    os.makedirs(dest, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tf:
        members = tf.getmembers()
        if not members:
            raise SystemExit("empty archive")
        root = members[0].name.split("/", 1)[0]
        for m in members:
            if m.isdir():
                continue
            rel = m.name[len(root) + 1 :] if m.name.startswith(root + "/") else m.name
            if not rel:
                continue
            out = os.path.join(dest, rel)
            os.makedirs(os.path.dirname(out), exist_ok=True)
            f = tf.extractfile(m)
            if f is None:
                continue
            with open(out, "wb") as out_f:
                out_f.write(f.read())
    print("archive_ok", dest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
