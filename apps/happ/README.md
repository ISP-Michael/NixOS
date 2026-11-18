# Happ

- Host: официальный `.deb` вручную в `/opt/happ`; обновление —
  `sudo apps/happ/update.sh`. Скрипт делает backup `/opt/happ.bak-*`,
  распаковывает `.deb` и перезапускает `happd`.
- ISO: `vendor/happ/module.nix` (pinned 4.7.2), activation раскладывает
  `/opt/happ`.
- Host-интеграция: `apps/happ/module.nix` — обёртка `happ`, desktop,
  `happd`, machine-id, tun/firewall.
- `~/.local/bin/happ` не должен перекрывать обёртку: если он есть, удалить
  или обновить на тот же путь.
- Конфиг: `~/.config/Happ` (1.3 МБ). Проверка: `command -v happ`,
  `systemctl status happd`, `ip -br addr`.
