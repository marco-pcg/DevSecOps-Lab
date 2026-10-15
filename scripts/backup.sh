#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_dir="$root/backups"
mkdir -p "$output_dir"
stamp="$(date -u +%Y%m%dT%H%M%SZ)"
archive="$output_dir/devsecops-lab-$stamp.tar.gz"

tar -czf "$archive" \
  --exclude='./.git' \
  --exclude='./backups' \
  -C "$root" README.md Dockerfile app compose security forgejo k8s scripts backup
sha256sum "$archive" > "$archive.sha256"
echo "created $archive"
echo "created $archive.sha256"

