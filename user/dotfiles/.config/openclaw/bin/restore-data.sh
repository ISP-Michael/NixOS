#!/usr/bin/env bash
# Restore OpenCode/OpenClaw data from the restic repo.
# Stop OpenCode/OpenClaw before restoring the database.
set -euo pipefail

HOME="${HOME:?}"
REPO="${RESTIC_REPOSITORY:-$HOME/Backups/opencode-restic}"
PASS="${RESTIC_PASSWORD_FILE:-$HOME/.local/state/opencode/restic.pass}"
FORCE="${FORCE:-0}"
DRY_RUN="${DRY_RUN:-0}"
TMPD="$(mktemp -d)"
trap 'rm -rf "$TMPD"' EXIT

[ -f "$PASS" ] || { echo "missing $PASS" >&2; exit 1; }
[ -f "$REPO/config" ] || { echo "missing restic repo $REPO" >&2; exit 1; }

export RESTIC_REPOSITORY="$REPO"
export RESTIC_PASSWORD_FILE="$PASS"

echo "restoring files..."
restic restore latest --tag opencode --target "$TMPD/files"
FILES_ROOT="$TMPD/files"
OLD_HOME="$(find "$FILES_ROOT/home" -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null || true)"
[ -n "$OLD_HOME" ] && FILES_ROOT="$OLD_HOME"

copy_path() {
  local src="$1" dst="$2"
  [ -e "$src" ] || return 0
  if [ -e "$dst" ] && [ "$FORCE" != "1" ]; then
    echo "skip   $dst (exists)"
    return 0
  fi
  if [ "$DRY_RUN" = "1" ]; then
    echo "would  copy $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    cp -a "$dst" "$dst.bak-$(date +%Y%m%d-%H%M%S)"
    rm -rf "$dst"
  fi
  cp -a "$src" "$dst"
  echo "restore $dst"
}

for p in \
  .local/share/opencode/memory \
  .local/share/opencode/snapshot \
  .openclaw/agents \
  .openclaw/state \
  .openclaw/workspace \
  .openclaw/media
do
  copy_path "$FILES_ROOT/$p" "$HOME/$p"
done

copy_path "$FILES_ROOT/.openclaw/openclaw.json" "$HOME/.openclaw/openclaw.json"

echo "restoring database..."
restic restore latest --tag opencode-db --target "$TMPD/db"
if [ -f "$TMPD/db/opencode.db" ]; then
  copy_path "$TMPD/db/opencode.db" "$HOME/.local/share/opencode/opencode.db"
else
  echo "database snapshot not found"
fi
