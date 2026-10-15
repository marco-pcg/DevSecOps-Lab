# DevSecOps Teaching Lab

A small, local-first repository for practicing a realistic DevSecOps progression:
application packaging, CI, secrets hygiene, SAST, dependency and image supply-chain
checks, signing, staging DAST, backups, Forgejo Actions, and Kubernetes.

The lab deliberately uses placeholders and binds every example service to
`127.0.0.1`. It does not contact an external service and it does not contain real
credentials.

## Prerequisites

- Git 2.30+
- Docker Engine or Docker Desktop with Compose v2
- Bash, `curl`, `sha256sum`, and a POSIX `tar`
- Optional: Python 3.11+, `semgrep`, `trivy`, `syft`, `cosign`, `kubectl`, and `k3d`

The optional tools can be installed with the package manager for your platform.
The examples explain where a tool is used and fail clearly when it is absent.

## Quick start

```bash
git clone <this-local-copy> devsecops-lab
cd devsecops-lab
cp .env.example .env
docker compose -f compose/docker-compose.dev.yml up --build
curl http://127.0.0.1:8080/health
docker compose -f compose/docker-compose.dev.yml down
```

Expected health response:

```json
{"service":"devsecops-lab","status":"ok"}
```

## Lesson progression

Each lesson is a real Git branch pointing at the corresponding milestone commit.
The final checkout includes all lessons. To follow the intended progression:

```bash
git branch --list 'lesson/*'
git switch lesson/00-foundation
# work through the lesson, then:
git switch lesson/01-compose-ci
```

| Branch | Focus | What to inspect |
| --- | --- | --- |
| `lesson/00-foundation` | Minimal app and reproducible repository | `app/`, `Dockerfile`, `.gitignore` |
| `lesson/01-compose-ci` | Local composition and CI checks | `compose/`, `.woodpecker.yml` |
| `lesson/02-secrets-sast` | Placeholder secrets and static analysis | `.env.example`, `security/semgrep.yml` |
| `lesson/03-dependencies-sbom` | Dependency audit and SBOM generation | `requirements.txt`, `security/trivy.yaml` |
| `lesson/04-image-signing` | Digest awareness and image signing workflow | `docs/image-signing.md` |
| `lesson/05-staging-dast` | Staging-like target and smoke/DAST checks | `compose/docker-compose.staging.yml`, `scripts/dast-smoke.sh` |
| `lesson/06-github-mirror-backups` | Offline backup and restore testing | `backup/`, `scripts/backup.sh`, `scripts/restore-test.sh` |
| `lesson/07-forgejo-actions` | Self-hosted Forgejo runner shape | `forgejo/` |
| `lesson/08-kubernetes` | k3d-compatible Kubernetes overlay | `k8s/` |

Use a detached worktree if you want to preserve the final checkout while
teaching a lesson:

```bash
git worktree add /tmp/devsecops-lesson-02 lesson/02-secrets-sast
```

## Validation

Run the repository's local checks:

```bash
./scripts/validate.sh
```

The validator checks YAML syntax when a YAML parser is available, shell syntax,
required files, and placeholder-only configuration. It does not require Docker.

Optional security checks:

```bash
semgrep --config security/semgrep.yml app
trivy fs --config security/trivy.yaml .
syft dir:. -o cyclonedx-json > /tmp/devsecops-lab-sbom.json
```

For image work:

```bash
docker build --tag devsecops-lab:local .
docker image inspect devsecops-lab:local --format '{{.Id}}'
```

`docs/image-signing.md` shows a local keyless-demo shape without embedding
private keys. Do not expose a signing key or use a production registry for this
exercise.

## Safety notes

- Every Compose port uses an explicit `127.0.0.1:` bind. Do not remove this
  restriction on a shared network.
- The Forgejo runner example mounts `/var/run/docker.sock` only to demonstrate
  the common pattern. A Docker socket gives the container host-level control;
  prefer rootless or isolated runners for anything beyond a disposable lab.
- Image tags are examples. For repeatable teaching, resolve an image digest
  (`docker image inspect` or a trusted registry) and record it in the lesson
  notes before using it in a long-lived environment.
- `.env.example` contains no secrets. Keep `.env` untracked and use obviously
  fake values for demonstrations.

## Staging and DAST

Start the staging-shaped target:

```bash
docker compose -f compose/docker-compose.staging.yml up --build -d
./scripts/dast-smoke.sh http://127.0.0.1:8081
docker compose -f compose/docker-compose.staging.yml down
```

The smoke script is intentionally small and safe. It verifies headers, health,
and an unknown route; it is not a substitute for a full authenticated DAST
program.

## Backups and restore testing

The backup example writes a compressed archive and checksum to `backups/`:

```bash
./scripts/backup.sh
./scripts/restore-test.sh backups/devsecops-lab-*.tar.gz
```

Restore testing extracts into a temporary directory and verifies the manifest.
It never overwrites the working tree. In a real system, add encryption,
off-host retention, access controls, and scheduled restore drills.

## Kubernetes / k3d

With a local k3d cluster:

```bash
k3d cluster create devsecops-lab --agents 1 --port '127.0.0.1:8082:30080@loadbalancer'
kubectl apply -k k8s/overlays/k3d
curl http://127.0.0.1:8082/health
kubectl delete -k k8s/overlays/k3d
k3d cluster delete devsecops-lab
```

The manifest uses the locally built image and `imagePullPolicy: IfNotPresent`.
If your cluster cannot see the image, import it with `k3d image import
devsecops-lab:local -c devsecops-lab`.

## Cleanup

```bash
docker compose -f compose/docker-compose.dev.yml down --volumes --remove-orphans
docker compose -f compose/docker-compose.staging.yml down --volumes --remove-orphans
rm -f .env
```

The commands above remove only this lab's Compose resources. Review
`docker volume ls` before removing anything manually.

