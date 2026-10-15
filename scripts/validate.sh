#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

required=(
  README.md Dockerfile .woodpecker.yml
  compose/docker-compose.dev.yml compose/docker-compose.staging.yml
  app/app.py security/semgrep.yml security/trivy.yaml
  forgejo/runner-config.example.yml k8s/overlays/k3d/kustomization.yaml
)
for file in "${required[@]}"; do
  test -f "$file" || { echo "missing required file: $file" >&2; exit 1; }
done

for script in scripts/*.sh; do
  bash -n "$script"
done

if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY'
import pathlib
try:
    import yaml
except ImportError:
    print("PyYAML unavailable; skipping YAML parse")
else:
    yaml_paths = [
        path for pattern in ("*.yml", "*.yaml")
        for path in pathlib.Path(".").rglob(pattern)
        if ".git" not in path.parts and "escape-rooms" not in path.parts
    ]
    for path in yaml_paths:
        yaml.safe_load(path.read_text())
    print("YAML parse: ok")
PY
fi

if grep -RInE 'password: *[^$<({[:space:]]|token: *[^$<({[:space:]]' \
  --exclude-dir=.git --exclude-dir=escape-rooms \
  --include='*.yml' --include='*.yaml' --include='*.env' .; then
  echo "possible hard-coded credential found" >&2
  exit 1
fi

echo "validation: ok"
