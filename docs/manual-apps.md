# Ручные приложения: /opt и официальные установщики

Host ставит свежие версии официальными установщиками; ISO — pinned-пакеты
из Nix store. Интеграция и рецепты — в `apps/`.

## AmneziaVPN

- Host: `/opt/AmneziaVPN`; обновление — `sudo apps/amnezia/update.sh`.
  Скрипт делает backup и откат.
- ISO: `apps/amnezia/package.nix` (5.1.0.6) + activation.
- Сервис/обёртка: `apps/amnezia/module.nix`.
- Конфиг: `~/.config/AmneziaVPN.ORG/AmneziaVPN.conf` (0600).
- Проверка: `systemctl status AmneziaVPN`, `ip -br addr`, `ip route`.

## Happ

- Host: `/opt/happ`; обновление — `sudo apps/happ/update.sh`.
- ISO: `vendor/happ/module.nix` (4.7.2).
- Host-интеграция: `apps/happ/module.nix`.
- `~/.local/bin/happ` не должен перекрывать обёртку.
- Проверка: `command -v happ`, `systemctl status happd`, `ip -br addr`.

## Throne

- Host: `/opt/Throne`; обновление — `sudo apps/throne/update.sh`.
- ISO не включает Throne.
- Интеграция: `apps/throne/module.nix`.
- Проверка: `command -v throne`, `ls -l /opt/Throne/ThroneCore`.

## OpenCode

- Host: `~/.opencode/bin/opencode`; обновление — `opencode-update.timer`
  (`apps/opencode/README.md`).
- ISO: `apps/opencode/package.nix` (2.3.0).
- Конфиг: `~/.config/opencode`; авторизация — `opencode auth login`.
- Проверка: `opencode --version`.

## OpenClaw

- Пока ручная установка Node/npm: `npm install --prefix "$HOME/.local" -g openclaw@<version>`.
- Конфиг: `user/dotfiles/.config/apps/install.sh` создаёт `~/.openclaw/openclaw.json`
  только если файла нет.
- Проверка: `openclaw --version`, `openclaw infer web search --query test`.
- SearXNG: host — Docker `127.0.0.1:8888`; ISO — native pinned package.

## FreesmLauncher

- Nix-пакет из flake (`freesmlauncher`), `/opt` не нужен.

## Что не копировать

- `~/.cache`, `node_modules`, браузерные профили;
- `openclaw.json`, `auth.json`, `service.json`, `*.db` — живые секреты/БД;
- `/opt`-бинари в git; только рецепт + бэкап конфига.
