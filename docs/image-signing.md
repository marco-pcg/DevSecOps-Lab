# Image signing lesson

Build a local image, inspect its immutable ID, and discuss why a mutable tag is
not an adequate deployment identity:

```bash
docker build --tag devsecops-lab:local .
docker image inspect devsecops-lab:local --format '{{.Id}}'
```

For a disposable local registry, use the Compose-style localhost binding below
and never publish it beyond the host:

```bash
docker run --rm -d --name lab-registry -p 127.0.0.1:5000:5000 \
  registry:2.8.3
docker tag devsecops-lab:local 127.0.0.1:5000/devsecops-lab:lesson
docker push 127.0.0.1:5000/devsecops-lab:lesson
```

If `cosign` is installed, prefer a temporary key pair outside the repository:

```bash
tmpdir="$(mktemp -d)"
cosign generate-key-pair --output-key-prefix "$tmpdir/lab"
# Sign only a local, disposable registry reference; do not commit the keys.
cosign sign --key "$tmpdir/lab.key" 127.0.0.1:5000/devsecops-lab:lesson
cosign verify --key "$tmpdir/lab.pub" 127.0.0.1:5000/devsecops-lab:lesson
rm -rf "$tmpdir"
docker rm -f lab-registry
```

The registry image tag is pinned as an example, but a real program should
resolve and record its digest before relying on it.

