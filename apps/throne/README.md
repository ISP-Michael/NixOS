# Throne

- Host: официальный `linux-amd64.zip` вручную в `/opt/Throne`; обновление —
  `sudo apps/throne/update.sh`. Скрипт делает backup `/opt/Throne.bak-*`,
  распаковывает zip и ставит `setuid` на `ThroneCore`.
- ISO не включает Throne: там Happ.
- Интеграция: `apps/throne/module.nix` — обёртки `throne`/`Throne`, desktop,
  polkit-правила для resolved.
- Проверка: `command -v throne`, `ls -l /opt/Throne/ThroneCore` (должен быть
  `rws`), запуск на пустом столе.
- Не держать одновременно два TUN-клиента (Throne/Happ/Amnezia).
