#!/usr/bin/env bash
# Ежедневная гигиена шлюза: сначала нативный restart (с TimeoutStopSec=30),
# если не поднялся — fallback kill -9 + start.
set -u
LOG="$HOME/.local/state/opencode/openclaw-gateway-restart.log"
LOCK="$HOME/.local/state/opencode/openclaw-maintenance.lock"

# не пересекаться с maintenance-проходом
exec 9>"$LOCK"
if ! flock -w 60 9; then
  echo "[$(date '+%F %T')] maintenance lock timeout; skip" >> "$LOG"
  exit 0
fi

health() {
  curl -sS -m 5 -o /dev/null -w '%{http_code}' http://127.0.0.1:18789/health 2>/dev/null
}

echo "[$(date '+%F %T')] restart requested" >> "$LOG"
if timeout 60 systemctl --user restart openclaw-gateway; then
  for _ in $(seq 1 15); do
    sleep 2
    if [ "$(health)" = "200" ]; then
      echo "[$(date '+%F %T')] ok (native restart)" >> "$LOG"
      exit 0
    fi
  done
fi

echo "[$(date '+%F %T')] native restart failed; kill -9 fallback" >> "$LOG"
systemctl --user kill -s KILL openclaw-gateway 2>/dev/null
sleep 2
systemctl --user start openclaw-gateway
for _ in $(seq 1 15); do
  sleep 2
  if [ "$(health)" = "200" ]; then
    echo "[$(date '+%F %T')] ok (kill -9 fallback)" >> "$LOG"
    exit 0
  fi
done
echo "[$(date '+%F %T')] FAILED health 200 not reached" >> "$LOG"
exit 1
