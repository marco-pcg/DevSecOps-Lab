#!/usr/bin/env python3
"""Tiny dependency-free HTTP service used by the teaching lab."""

import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Handler(BaseHTTPRequestHandler):
    server_version = "DevSecOpsLab/1.0"

    def _send(self, status, body):
        payload = json.dumps(body).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):  # noqa: N802 - required by BaseHTTPRequestHandler
        if self.path == "/health":
            self._send(200, {"service": "devsecops-lab", "status": "ok"})
        elif self.path == "/":
            self._send(200, {"service": "devsecops-lab", "message": "ready"})
        else:
            self._send(404, {"error": "not found"})

    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args), flush=True)


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()

