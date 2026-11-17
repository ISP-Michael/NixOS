#!/usr/bin/env bash
# Seed the Telegram bot token from the sops secret into OpenClaw's secret store.
# Skips silently if the secret is still the REPLACE_ME placeholder.
set -u
token="${1:-}"
[ -f "$token" ] || exit 0
grep -q '^REPLACE_ME$' "$token" && exit 0

OPENCLAW="${OPENCLAW_BIN:-$(command -v openclaw 2>/dev/null || true)}"
[ -x "$OPENCLAW" ] || OPENCLAW="$HOME/.local/bin/openclaw"
[ -x "$OPENCLAW" ] || exit 0

"$OPENCLAW" secrets store set TELEGRAM_BOT_TOKEN_V3 --value-file "$token" || true
