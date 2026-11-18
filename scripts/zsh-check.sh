#!/usr/bin/env bash
# Static checks for the portable zsh config. Does not source the live .zshrc.
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh not found; skipping" >&2
  exit 0
fi

for file in \
  user/dotfiles/.config/zsh/.zshenv \
  user/dotfiles/.config/zsh/.zshrc \
  user/dotfiles/.config/zsh/manifest.zsh \
  user/dotfiles/.config/zsh/rc/*.zsh
do
  zsh -n "$file"
done

if git grep -n '/home/Michael' -- user/dotfiles/.config/zsh; then
  echo "hardcoded host path in portable zsh config" >&2
  exit 1
fi

for stale in \
  .zcompdump \
  .zshrc.bak-2026-11-16 \
  plugins.zsh \
  plugins_lazy.zsh
do
  if [ -e "user/dotfiles/.config/zsh/$stale" ]; then
    echo "stale generated file in zsh config: $stale" >&2
    exit 1
  fi
done

echo "zsh checks passed"
