#!/usr/bin/env bash
set -euo pipefail

archive="${1:?usage: restore-test.sh backups/devsecops-lab-*.tar.gz}"
test -f "$archive"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
tar -xzf "$archive" -C "$tmpdir"
test -f "$tmpdir/README.md"
test -f "$tmpdir/Dockerfile"
test -f "$tmpdir/app/app.py"
test -f "$tmpdir/backup/manifest.txt"
echo "restore test: ok ($archive)"

