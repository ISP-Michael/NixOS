#!/usr/bin/env bash
# Не запускать тяжёлые задачи, пока пользователь играет: на 6 ГБ сборка,
# eval или большая загрузка отбирают CPU/диск и роняют композитор.
#
# Ловим именно игру, а не оболочку Lutris: после выхода из игры
# lutris-wrapper и Wine-сервисы могут висеть ещё часы.
#
# Обход для осознанного случая: ALLOW_GAMING=1.
set -euo pipefail

if [ "${ALLOW_GAMING:-0}" = "1" ]; then
  exit 0
fi

# Proton/Lutris/Steam запускают игру через waitforexitandrun или gamescope;
# список exe — для игр, которые запускаются без этих обёрток.
PATTERN='waitforexitandrun|gamescope|steam_app_|Cuphead\.exe|Hollow Knight.*\.exe|Silksong\.exe|Stardew Valley\.exe|Terraria\.exe|Dead Cells\.exe'

if pgrep -af "$PATTERN" >/dev/null 2>&1; then
  echo "game is running; heavy jobs are paused (ALLOW_GAMING=1 to override)" >&2
  exit 1
fi
