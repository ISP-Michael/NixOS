#!/usr/bin/env bash
# Back up app configs that live outside /etc/nixos. Archive is 0600.
set -euo pipefail
OUT_DIR="${OUT_DIR:-$HOME/Backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$OUT_DIR/manual-configs-$STAMP.tar.gz"
mkdir -p "$OUT_DIR"
umask 077

paths=()
for p in \
  "$HOME/.config/AmneziaVPN.ORG" \
  "$HOME/.config/Happ" \
  "$HOME/.config/Throne" \
  "$HOME/.config/qBittorrent" \
  "$HOME/.config/searxng"; do
  [ -e "$p" ] && paths+=("$p")
done
[ "${#paths[@]}" -gt 0 ] || { echo "nothing to backup" >&2; exit 1; }

tar -czf "$OUT" --absolute-names "${paths[@]}"
chmod 600 "$OUT"
echo "backup: $OUT"
echo "restore: tar -xzf $OUT -C /"
