# Escape-room modules

This directory is reserved for the three escape-room teaching projects. Each
room should be added as a Git submodule once its canonical repository URL is
known:

```bash
git submodule add <room-01-url> escape-rooms/room-01
git submodule add <room-02-url> escape-rooms/room-02
git submodule add <room-03-url> escape-rooms/room-03
git commit -m "integrate escape-room teaching modules"
```

Do not copy room contents into this repository. Submodules preserve each
project's independent history while this repository pins the exact commit used
by a lesson.

After cloning the unified repository:

```bash
git clone --recurse-submodules <teaching-devsecops-url>
# or, after a normal clone:
git submodule update --init --recursive
```

The room repositories are intentionally not guessed here. GitHub's public API
currently exposes only `MarcoPCG/CalcNT` and `MarcoPCG/Calculadora-NT`; neither
is an escape-room project. Add the real URLs when the repositories are made
visible or their names are provided.

