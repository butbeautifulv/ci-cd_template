#!/usr/bin/env python3
"""Minimal HTTP stub for ephemeral CI deploy of map_objects services.

Satisfies data_lake lifespan:
  POST .../apiauth → {"access_token": "..."}
  GET  .../variation/<name>/items → []
Other methods return {} / [].
"""
from __future__ import annotations

import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def _send(self, code: int = 200, body: bytes = b"{}") -> None:
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _read_body(self) -> bytes:
        length = int(self.headers.get("Content-Length") or 0)
        return self.rfile.read(length) if length else b""

    def do_GET(self) -> None:  # noqa: N802
        if "/items" in self.path:
            self._send(200, b"[]")
        else:
            self._send(200, b"{}")

    def do_POST(self) -> None:  # noqa: N802
        self._read_body()
        if "apiauth" in self.path:
            self._send(
                200,
                json.dumps({"access_token": "ci-stub-token", "token_type": "bearer"}).encode(),
            )
        elif "/items" in self.path:
            self._send(200, b"[]")
        else:
            self._send(200, b"[]")

    def do_PATCH(self) -> None:  # noqa: N802
        self.do_POST()

    def do_PUT(self) -> None:  # noqa: N802
        self.do_POST()

    def log_message(self, fmt: str, *args) -> None:  # noqa: A003
        return


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8000), Handler).serve_forever()
