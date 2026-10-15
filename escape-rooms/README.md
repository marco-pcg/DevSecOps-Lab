# Escape-room modules

This directory contains the three escape-room teaching projects as Git
submodules:

| Module | Repository | Purpose |
| --- | --- | --- |
| `escape_room_git_3` | `profdiegocbcastro/escape_room_git_3` | Escape room 3 |
| `escape_room_git_4` | `marco-pcg/escape_room_git_4` | Escape room 4 |
| `escape_room_git_5` | `marco-pcg/escape_room_git_5` | Escape room 5 |

The parent repository pins the exact commit used by the teaching checkout.

Do not copy room contents into this repository. Submodules preserve each
project's independent history while this repository pins the exact commit used
by a lesson.

After cloning the unified repository:

```bash
git clone --recurse-submodules <teaching-devsecops-url>
# or, after a normal clone:
git submodule update --init --recursive
```

Room 3 is the public repository shown as the source of the fork in the profile
view; rooms 4 and 5 are the public repositories owned by `marco-pcg`.

To add a replacement module in a future checkout:

```bash
./scripts/add-escape-room.sh escape_room_git_4 <repository-url>
```
