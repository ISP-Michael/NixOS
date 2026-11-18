#!/usr/bin/env bash
# Read-only health snapshot for the manual parts of the system.
set -uo pipefail

echo "== system =="
hostname
uname -r
uptime -p 2>/dev/null || true

echo "== units =="
for u in fprintd keyd AmneziaVPN happd; do
  printf '%-16s ' "$u"
  systemctl is-active "$u" 2>/dev/null || true
done
for u in usque.service usque-http.service; do
  if systemctl --user is-enabled "$u" >/dev/null 2>&1; then
    printf '%-16s ' "$u"
    systemctl --user is-active "$u" 2>/dev/null || true
  fi
done

echo "== user timers =="
systemctl --user list-timers --all --no-pager 2>/dev/null \
  | rg -i 'opencode|openclaw|backup|update' || true

echo "== /opt apps =="
for p in /opt/AmneziaVPN/bin/AmneziaVPN /opt/happ/bin/Happ /opt/Throne/Throne; do
  if [ -x "$p" ]; then
    printf '%-40s OK\n' "$p"
  else
    printf '%-40s MISSING\n' "$p"
  fi
done

echo "== SearXNG =="
curl -sS --max-time 5 'http://127.0.0.1:8888/search?q=health&format=json' -o /dev/null \
  -w 'http=%{http_code}\n' 2>/dev/null || echo "unreachable"

echo "== fingerprint =="
fprintd-list "${USER:-Michael}" 2>&1 | head -8 || true

echo "== restic =="
export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-$HOME/Backups/opencode-restic}"
export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-$HOME/.local/state/opencode/restic.pass}"
if [ -f "$RESTIC_PASSWORD_FILE" ] && [ -d "$RESTIC_REPOSITORY" ]; then
  restic snapshots --latest 1 2>&1 | tail -5
else
  echo "restic repo/password missing"
fi
