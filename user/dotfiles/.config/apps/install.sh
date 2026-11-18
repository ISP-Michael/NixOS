#!/usr/bin/env bash
# Bootstrap OpenCode/OpenClaw configs.
# Default: symlink static files, render templates with @HOME@/@PYTHON@/@CHROMIUM@.
# Never overwrites existing files unless --force (then makes .bak).
# Never touches live secrets/DBs: openclaw.json (if present), auth.json,
# service.json, *.db, node_modules, sessions.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
HOME="${HOME:?}"
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"
MODE="${MODE:-link}"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force) FORCE=1 ;;
    --copy) MODE=copy ;;
    --link) MODE=link ;;
    -h|--help)
      sed -n '2,7p' "$0"
      exit 0
      ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

PYTHON_BIN="$(command -v python3 || true)"
[ -n "$PYTHON_BIN" ] || PYTHON_BIN="/usr/bin/env python3"
CHROMIUM_BIN="${CHROMIUM_BIN:-$(command -v chromium || true)}"
[ -n "$CHROMIUM_BIN" ] || CHROMIUM_BIN="/run/current-system/sw/bin/chromium"
PROFILE_DIR="/etc/profiles/per-user/$(id -un)"
NODE_BIN=""
for n in "$HOME"/.local/node/*/bin/node; do
  [ -x "$n" ] && NODE_BIN="$n"
done
if [ -z "$NODE_BIN" ]; then
  NODE_BIN="$(command -v node || true)"
fi
[ -n "$NODE_BIN" ] || NODE_BIN="/usr/bin/env node"
NODE_DIR="$(dirname "$NODE_BIN")"

run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf 'would  %s\n' "$*"
  else
    "$@"
  fi
}

backup() {
  local dst="$1"
  [ -e "$dst" ] || return 0
  local bak="$dst.bak-$(date +%Y%m%d-%H%M%S)"
  run cp -a "$dst" "$bak"
  echo "backup $bak"
}

link_file() {
  local src="$1" dst="$2"
  [ -e "$src" ] || { echo "skip   $src (missing source)"; return 0; }
  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      echo "ok     $dst"
      return 0
    fi
    if [ "$FORCE" != "1" ]; then
      echo "skip   $dst (symlink exists, not touching)"
      return 0
    fi
    run rm -f "$dst"
  elif [ -e "$dst" ]; then
    if [ "$FORCE" != "1" ]; then
      echo "skip   $dst (exists, not touching)"
      return 0
    fi
    backup "$dst"
    run rm -f "$dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  echo "link   $dst -> $src"
}

link_dir() {
  local src="$1" dst="$2"
  [ -d "$src" ] || { echo "skip   $src (missing source dir)"; return 0; }
  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      echo "ok     $dst"
      return 0
    fi
    if [ "$FORCE" != "1" ]; then
      echo "skip   $dst (symlink exists, not touching)"
      return 0
    fi
    run rm -f "$dst"
  elif [ -e "$dst" ]; then
    if [ "$FORCE" != "1" ]; then
      echo "skip   $dst (exists, not touching)"
      return 0
    fi
    backup "$dst"
    run rm -rf "$dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  echo "link   $dst -> $src"
}

copy_file() {
  local src="$1" dst="$2" mode="${3:-600}"
  [ -e "$src" ] || { echo "skip   $src (missing source)"; return 0; }
  if [ -e "$dst" ]; then
    if [ "$FORCE" != "1" ]; then
      echo "skip   $dst (exists, not touching)"
      return 0
    fi
    backup "$dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run install -m "$mode" "$src" "$dst"
  echo "copy   $dst"
}

render_file() {
  local src="$1" dst="$2" mode="${3:-600}"
  [ -e "$src" ] || { echo "skip   $src (missing template)"; return 0; }
  local tmp
  tmp="$(mktemp)"
  sed \
    -e "s#@HOME@#${HOME}#g" \
    -e "s#@PYTHON@#${PYTHON_BIN}#g" \
    -e "s#@CHROMIUM@#${CHROMIUM_BIN}#g" \
    -e "s#@PROFILE@#${PROFILE_DIR}#g" \
    -e "s#@NODE@#${NODE_BIN}#g" \
    -e "s#@NODE_DIR@#${NODE_DIR}#g" \
    "$src" > "$tmp"
  if [ -e "$dst" ] && [ "$FORCE" != "1" ]; then
    echo "skip   $dst (exists, not touching)"
    rm -f "$tmp"
    return 0
  fi
  if [ -e "$dst" ]; then
    backup "$dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run install -m "$mode" "$tmp" "$dst"
  echo "render $dst"
  rm -f "$tmp"
}

create_file() {
  local src="$1" dst="$2" mode="${3:-600}"
  if [ -e "$dst" ]; then
    echo "ok     $dst (live, not touching)"
    return 0
  fi
  render_file "$src" "$dst" "$mode"
}

copy_dir() {
  local src="$1" dst="$2"
  [ -d "$src" ] || { echo "skip   $src (missing source dir)"; return 0; }
  if [ -e "$dst" ]; then
    if [ "$FORCE" != "1" ]; then
      echo "skip   $dst (exists, not touching)"
      return 0
    fi
    backup "$dst"
    run rm -rf "$dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run cp -a "$src" "$dst"
  echo "copy   $dst"
}

install_units() {
  local dir rel
  for dir in "$SRC/openclaw/systemd/user" "$SRC/opencode/systemd/user"; do
    [ -d "$dir" ] || continue
    while IFS= read -r -d '' f; do
      rel="${f#"$dir/"}"
      render_file "$f" "$HOME/.config/systemd/user/$rel" 644
    done < <(find "$dir" -type f -print0)
  done
}

echo "== OpenCode =="
render_file "$SRC/opencode/opencode.jsonc.tmpl" "$HOME/.config/opencode/opencode.jsonc" 600
if [ "$MODE" = "copy" ]; then
  copy_file "$SRC/opencode/cli.json" "$HOME/.config/opencode/cli.json" 600
  copy_file "$SRC/opencode/package.json" "$HOME/.config/opencode/package.json" 644
  copy_dir "$SRC/opencode/plugins" "$HOME/.config/opencode/plugins"
else
  link_file "$SRC/opencode/cli.json" "$HOME/.config/opencode/cli.json"
  link_file "$SRC/opencode/package.json" "$HOME/.config/opencode/package.json"
  link_dir "$SRC/opencode/plugins" "$HOME/.config/opencode/plugins"
fi

if [ "$MODE" = "copy" ]; then
  copy_file "$SRC/opencode/bin/opencode-update" "$HOME/.local/bin/opencode-update" 755
else
  link_file "$SRC/opencode/bin/opencode-update" "$HOME/.local/bin/opencode-update"
fi

echo "== OpenClaw =="
create_file "$SRC/openclaw/openclaw.json.tmpl" "$HOME/.openclaw/openclaw.json" 600
if [ "$MODE" = "copy" ]; then
  copy_file "$SRC/openclaw/bin/openclaw-maintenance.py" "$HOME/.local/state/opencode/openclaw-maintenance.py" 755
  copy_file "$SRC/openclaw/bin/openclaw-report.py" "$HOME/.local/state/opencode/openclaw-report.py" 755
  copy_file "$SRC/openclaw/bin/openclaw-gateway-restart.sh" "$HOME/.local/state/opencode/openclaw-gateway-restart.sh" 755
  copy_file "$SRC/openclaw/bin/openclaw-seed-telegram.sh" "$HOME/.local/state/opencode/openclaw-seed-telegram.sh" 755
  copy_file "$SRC/openclaw/bin/backup-data.sh" "$HOME/.local/state/opencode/backup-data.sh" 755
  copy_file "$SRC/openclaw/bin/restore-data.sh" "$HOME/.local/state/opencode/restore-data.sh" 755
else
  link_file "$SRC/openclaw/bin/openclaw-maintenance.py" "$HOME/.local/state/opencode/openclaw-maintenance.py"
  link_file "$SRC/openclaw/bin/openclaw-report.py" "$HOME/.local/state/opencode/openclaw-report.py"
  link_file "$SRC/openclaw/bin/openclaw-gateway-restart.sh" "$HOME/.local/state/opencode/openclaw-gateway-restart.sh"
  link_file "$SRC/openclaw/bin/openclaw-seed-telegram.sh" "$HOME/.local/state/opencode/openclaw-seed-telegram.sh"
  link_file "$SRC/openclaw/bin/backup-data.sh" "$HOME/.local/state/opencode/backup-data.sh"
  link_file "$SRC/openclaw/bin/restore-data.sh" "$HOME/.local/state/opencode/restore-data.sh"
fi

echo "== systemd units =="
install_units

if [ "$DRY_RUN" != "1" ]; then
  chmod +x "$HOME/.local/state/opencode/openclaw-maintenance.py" 2>/dev/null || true
  chmod +x "$HOME/.local/state/opencode/openclaw-report.py" 2>/dev/null || true
  chmod +x "$HOME/.local/state/opencode/openclaw-gateway-restart.sh" 2>/dev/null || true
  chmod +x "$HOME/.local/state/opencode/openclaw-seed-telegram.sh" 2>/dev/null || true
  chmod +x "$HOME/.local/state/opencode/backup-data.sh" 2>/dev/null || true
  chmod +x "$HOME/.local/state/opencode/restore-data.sh" 2>/dev/null || true
  chmod +x "$HOME/.local/bin/opencode-update" 2>/dev/null || true
fi

if [ "${SKIP_NPM:-0}" != "1" ] && [ ! -d "$HOME/.config/opencode/node_modules" ]; then
  if command -v npm >/dev/null 2>&1; then
    echo "== npm =="
    run npm install --prefix "$HOME/.config/opencode" --no-audit --no-fund
  else
    echo "warn: npm not found; install node_modules manually" >&2
  fi
else
  echo "ok     node_modules present"
fi

if [ "$DRY_RUN" != "1" ]; then
  systemctl --user daemon-reload 2>/dev/null || true
fi

cat <<'EOF'

Готово. Включить таймеры (один раз):
  systemctl --user enable --now openclaw-maintenance.timer
  systemctl --user enable --now openclaw-gateway-restart.timer
  systemctl --user enable --now opencode-backup.timer
  systemctl --user enable --now opencode-update.timer

Секреты не переносятся. Если ~/.openclaw/openclaw.json только что создан,
вставь токены вместо REPLACE_ME. Живые auth.json/service.json/БД не тронуты.

EOF
