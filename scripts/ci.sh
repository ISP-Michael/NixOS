#!/usr/bin/env bash
# Read-only checks.
#
# Default (make check): только хостовая конфигурация и проверки dotfiles.
# --full (make ci, GitHub Actions): все конфигурации и ISO-пакеты.
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/guard-gaming.sh

MODE="quick"
case "${1:-}" in
  --full)
    MODE="full"
    ;;
  "")
    ;;
  *)
    echo "usage: $0 [--full]" >&2
    exit 2
    ;;
esac

if [ "${ALLOW_DIRTY:-0}" != "1" ] && [ -n "$(git status --porcelain)" ]; then
  echo "working tree is dirty; commit/stage first or set ALLOW_DIRTY=1" >&2
  exit 1
fi

git diff --check

configs=(
  "MagicBook"
)
packages=()

if [ "$MODE" = "full" ]; then
  configs=(
    "MagicBook"
    "MagicBookInstall"
    "iso-lite"
    "iso"
    "iso-custom"
    "iso-media"
    "iso-full"
  )
  packages=(
    "iso-lite"
    "iso"
    "iso-custom"
    "iso-media"
    "iso-full"
  )
fi

for name in "${configs[@]}"; do
  nix eval --raw ".#nixosConfigurations.${name}.config.system.build.toplevel.drvPath" >/dev/null
  echo "OK config ${name}"
done

for name in "${packages[@]}"; do
  nix eval --raw ".#packages.x86_64-linux.${name}.outPath" >/dev/null
  echo "OK package ${name}"
done

./scripts/hypr-check.sh
./scripts/zsh-check.sh
./scripts/nvim-check.sh

echo "all checks passed"
