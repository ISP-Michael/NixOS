#!/usr/bin/env bash
# Восстанавливает живые файлы из зашифрованного снимка.
# По умолчанию не перезаписывает существующие; FORCE=1 — перезаписать с .bak.
set -euo pipefail

ROOT="${ROOT:-/etc/nixos}"
ARCHIVE="$ROOT/secrets/apps.yaml"
[ -f "$ARCHIVE" ] || { echo "no archive: $ARCHIVE" >&2; exit 1; }
FORCE="${FORCE:-0}"
TMPD=$(mktemp -d /tmp/opencode/apps-restore.XXXXXX)
trap 'rm -rf "$TMPD"' EXIT

extract() {
  local key="$1" out="$2"
  sops --config "$ROOT/.sops.yaml" -d --extract "[\"$key\"]" "$ARCHIVE" > "$out" 2>/dev/null
}

restore_file() {
  local src="$1" dst="$2"
  if [ ! -s "$src" ]; then
    return 1
  fi
  if [ -e "$dst" ] && [ "$FORCE" != "1" ]; then
    echo "skip    $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    cp -a "$dst" "$dst.bak-$(date +%s)"
  fi
  install -m 600 "$src" "$dst"
  echo "restore $dst"
}

if extract openclaw-json "$TMPD/openclaw.json"; then
  restore_file "$TMPD/openclaw.json" "$HOME/.openclaw/openclaw.json" || true
else
  echo "archive: openclaw-json missing"
fi

if extract opencode-auth-json "$TMPD/auth.json"; then
  restore_file "$TMPD/auth.json" "$HOME/.local/share/opencode/auth.json" || true
else
  echo "archive: opencode-auth-json missing"
fi

if extract telegram-bot-token "$TMPD/token"; then
  if ! grep -q '^REPLACE_ME$' "$TMPD/token"; then
    SEED="$(cd "$(dirname "$0")/../openclaw/bin" && pwd)/openclaw-seed-telegram.sh"
    if [ -x "$SEED" ]; then
      "$SEED" "$TMPD/token" || true
      echo "telegram token: seeded"
    fi
  else
    echo "telegram token: placeholder, skipped"
  fi
fi

if extract opencode-service-password "$TMPD/service-password" 2>/dev/null; then
  echo "service password: present in archive (service.json is not overwritten)"
fi
