#!/usr/bin/env bash
set -euo pipefail

base_url="${1:-http://127.0.0.1:8081}"
curl --fail --silent --show-error "$base_url/health" | grep -q '"status": "ok"'
headers="$(curl --fail --silent --show-error --dump-header - "$base_url/health" -o /dev/null)"
grep -qi '^X-Content-Type-Options: nosniff' <<<"$headers"
test "$(curl --silent --output /dev/null --write-out '%{http_code}' "$base_url/not-found")" = 404
echo "DAST smoke checks: ok ($base_url)"

