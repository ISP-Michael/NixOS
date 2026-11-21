#!/usr/bin/env bash
# Не запускать тяжёлые задачи, пока пользователь играет: на 6 ГБ сборка,
# eval или большая загрузка отбирают CPU/диск и роняют композитор.
#
# Обход для осознанного случая: ALLOW_GAMING=1.
set -euo pipefail

if [ "${ALLOW_GAMING:-0}" = "1" ]; then
  exit 0
fi

if pgrep -af 'waitforexitandrun|lutris-wrapper|gamescope|steam_app_|Hollow Knight' >/dev/null 2>&1; then
  echo "game is running; heavy jobs are paused (ALLOW_GAMING=1 to override)" >&2
  exit 1
fi
