#!/usr/bin/env bash
set -euo pipefail

room="${1:?usage: add-escape-room.sh <escape_room_git_3|escape_room_git_4|escape_room_git_5> <repository-url>}"
url="${2:?usage: add-escape-room.sh <escape_room_git_3|escape_room_git_4|escape_room_git_5> <repository-url>}"

case "$room" in
  escape_room_git_3|escape_room_git_4|escape_room_git_5) ;;
  *) echo "room must be escape_room_git_3, escape_room_git_4, or escape_room_git_5" >&2; exit 2 ;;
esac

case "$url" in
  https://github.com/*/*.git|https://github.com/*/*|git@github.com:*/*) ;;
  *) echo "use a GitHub repository URL" >&2; exit 2 ;;
esac

test ! -e "escape-rooms/$room" || {
  echo "escape-rooms/$room already exists; inspect it before replacing it" >&2
  exit 1
}

git submodule add "$url" "escape-rooms/$room"
echo "Added $room. Review the pinned commit, then commit .gitmodules and the submodule entry."
