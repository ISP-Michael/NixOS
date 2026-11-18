# AmneziaVPN

- Host: официальный `.run` вручную в `/opt/AmneziaVPN`; обновление —
  `sudo apps/amnezia/update.sh`. Скрипт делает backup `/opt/AmneziaVPN.bak-*`
  и откат при ошибке.
- ISO: `apps/amnezia/package.nix` (pinned 5.1.0.6) + activation в
  `apps/amnezia/module.nix`.
- Сервис/обёртка: `apps/amnezia/module.nix`; `services.amnezia-vpn.enable`.
- Конфиг: `~/.config/AmneziaVPN.ORG/AmneziaVPN.conf` (0600). Бэкап — отдельно,
  в git не кладётся.
- Проверка: `systemctl status AmneziaVPN`, `ip -br addr`, `ip route`.
  `active` ≠ туннель поднят.
