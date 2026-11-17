#!/usr/bin/env bash
# Incremental restic backup of OpenCode/OpenClaw data (sessions, memory).
# Repo and password are outside git:
#   /etc/nixos/secrets/opencode-restic/   (gitignored)
#   ~/.local/state/opencode/restic.pass   (0600)
set -euo pipefail

HOME="${HOME:?}"
REPO="${RESTIC_REPOSITORY:-/etc/nixos/secrets/opencode-restic}"
PASS="${RESTIC_PASSWORD_FILE:-$HOME/.local/state/opencode/restic.pass}"
HOST="$(hostname -s)"
TMPD="$(mktemp -d)"
trap 'rm -rf "$TMPD"' EXIT

mkdir -p "$HOME/.local/state/opencode"
exec 9>"$HOME/.local/state/opencode/backup.lock"
if ! flock -n 9; then
  echo "backup already running; skip"
  exit 0
fi

mkdir -p "$(dirname "$REPO")" "$(dirname "$PASS")"
if [ ! -f "$PASS" ]; then
  umask 077
  openssl rand -base64 32 > "$PASS"
  chmod 600 "$PASS"
  echo "generated restic password: $PASS" >&2
fi

export RESTIC_REPOSITORY="$REPO"
export RESTIC_PASSWORD_FILE="$PASS"

if [ ! -f "$REPO/config" ]; then
  restic init
fi

if [ -f "$HOME/.local/share/opencode/opencode.db" ]; then
  sqlite3 "$HOME/.local/share/opencode/opencode.db" ".backup '$TMPD/opencode.db'"
fi

cd "$HOME"

paths=()
for p in \
  .local/share/opencode/memory \
  .local/share/opencode/snapshot \
  .openclaw/agents \
  .openclaw/state \
  .openclaw/workspace \
  .openclaw/media \
  .openclaw/openclaw.json
do
  [ -e "$p" ] && paths+=("$p")
done

if [ "${#paths[@]}" -gt 0 ]; then
  restic backup \
    --tag opencode \
    --host "$HOST" \
    --exclude '*.log' \
    --exclude '*.tmp' \
    --exclude 'cache' \
    --exclude 'browser' \
    "${paths[@]}"
fi

if [ -f "$TMPD/opencode.db" ]; then
  restic backup \
    --tag opencode-db \
    --host "$HOST" \
    --stdin \
    --stdin-filename opencode.db < "$TMPD/opencode.db"
fi

restic forget \
  --host "$HOST" \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6 \
  --prune
