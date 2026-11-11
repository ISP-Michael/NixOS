#!/usr/bin/env bash
# Копирует конфиги/юниты/скрипты OpenCode/OpenClaw в реальные директории.
# Секреты и живые конфиги не трогает. Существующие файлы не перезаписывает
# без FORCE=1 (тогда делает .bak).
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
HOME="${HOME:?}"
FORCE="${FORCE:-0}"

copy() {
  src="$1"
  dst="$2"
  if [ -e "$dst" ] && [ "$FORCE" != "1" ]; then
    echo "skip   $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    cp -a "$dst" "$dst.bak-$(date +%s)"
  fi
  cp -a "$src" "$dst"
  echo "copy   $dst"
}

copy "$SRC/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
copy "$SRC/opencode/cli.json" "$HOME/.config/opencode/cli.json"

PYTHON_BIN="$(command -v python3 || true)"
[ -n "$PYTHON_BIN" ] || PYTHON_BIN="/usr/bin/env python3"
for unit in openclaw-maintenance.service openclaw-dashboard-web.service; do
  if [ -f "$HOME/.config/systemd/user/$unit" ]; then
    sed -i "s#@PYTHON@#${PYTHON_BIN}#g" "$HOME/.config/systemd/user/$unit"
  fi
done
if [ -f "$HOME/.config/systemd/user/openclaw-gateway.service" ]; then
  sed -i "s#/home/Michael#${HOME}#g" "$HOME/.config/systemd/user/openclaw-gateway.service"
fi

# user units (включая drop-in'ы)
while IFS= read -r -d '' f; do
  rel="${f#"$SRC/openclaw/systemd/user/"}"
  copy "$f" "$HOME/.config/systemd/user/$rel"
done < <(find "$SRC/openclaw/systemd/user" -type f -print0)

# скрипты обслуживания
for s in openclaw-maintenance.py openclaw-report.py openclaw-gateway-restart.sh openclaw-seed-telegram.sh; do
  copy "$SRC/openclaw/bin/$s" "$HOME/.local/state/opencode/$s"
  chmod +x "$HOME/.local/state/opencode/$s"
done

systemctl --user daemon-reload || true

cat <<'EOF'

Скопировано. Включить таймеры/сервис (один раз):
  systemctl --user enable --now openclaw-maintenance.timer
  systemctl --user enable --now openclaw-gateway-restart.timer
  systemctl --user enable --now openclaw-dashboard-web.service

Конфиг OpenClaw и auth.json не копируются: они живые, их восстанавливает
restore.sh из зашифрованного снимка (или ты кладёшь их сам).
EOF
