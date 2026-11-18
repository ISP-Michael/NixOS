#!/usr/bin/env bash
# Validate both Hyprland Lua entry points without starting a compositor.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v Hyprland >/dev/null 2>&1; then
  echo "Hyprland not found; skipping Hyprland config check" >&2
  exit 0
fi

for config in \
  user/dotfiles/.config/hypr/hyprland.lua \
  iso/config/hypr/hyprland.lua
do
  echo "checking $config"
  Hyprland --verify-config -c "$PWD/$config" 2>&1 |
    sed -n '/Config parsing result/,$p'
done
