#!/usr/bin/env bash
# Build or switch the host after CI checks.
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="${HOST:-MagicBook}"
MODE="${1:-switch}"

# Быстрый предполётный контроль. Полный ci.sh (eval всех 7 конфигураций и
# 5 ISO) на 6 ГБ уходит в своп и дублирует eval, который nixos-rebuild
# всё равно делает сам. Полная проверка — `make ci` перед пушем.
if [ "${ALLOW_DIRTY:-0}" != "1" ] && [ -n "$(git status --porcelain)" ]; then
  echo "dirty tree: commit changes or set ALLOW_DIRTY=1" >&2
  git status --short >&2
  exit 1
fi
git diff --check

case "$MODE" in
  build)
    nixos-rebuild build --flake ".#${HOST}"
    ;;
  switch)
    nixos-rebuild switch --flake ".#${HOST}" --sudo
    ;;
  *)
    echo "usage: $0 [build|switch]" >&2
    exit 2
    ;;
esac
