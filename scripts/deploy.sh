#!/usr/bin/env bash
# Build or switch the host after CI checks.
set -euo pipefail
cd "$(dirname "$0")/.."

HOST="${HOST:-MagicBook}"
MODE="${1:-switch}"
./scripts/ci.sh

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
