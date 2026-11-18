#!/bin/sh
# Thin wrapper so every app has a predictable update entrypoint.
exec "$(dirname "$0")/../../user/dotfiles/.config/opencode/bin/opencode-update" "$@"
