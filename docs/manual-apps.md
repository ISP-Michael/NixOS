# Ручные приложения: что копировать и чем проверять

Это дополнение к `docs/transfer.md`. Здесь — приложения, которые живут вне Nix
или требуют `/opt`. Секреты и токены сюда не пишем.

## OpenCode

- На ISO `work`/`custom` уже есть OpenCode 2.3.0 (официальный релиз).
- На обычной машине: официальный установщик или готовый бинарь; nixpkgs-пакет
  2.2.5 собирается не всегда.
- Конфиг: `install.sh` (см. `user/dotfiles/.config/apps/README.md`), затем `opencode auth login`.
- Проверка: `opencode --version`; `opencode auth list`.

## OpenClaw

- Нужен Node 26.x и npm. На ISO `work`/`custom` есть `nodejs_latest`, npm
  с prefix `~/.npm`.
- Установка (пример, версию сверить с `~/.openclaw`/релизом):
  ```bash
  node --version
  npm install --prefix "$HOME/.local" -g openclaw@2026.10.6
  ```
  Бинарь окажется в `~/.local/bin/openclaw`; `~/.local/bin` должен быть в PATH.
- Конфиг: `install.sh` создаёт `~/.openclaw/openclaw.json` только если файла
  нет; токены вставить вручную.
- Проверка: `openclaw --version`, `openclaw infer web search --query test`.
- SearXNG: на ISO `work`/`custom` поднимается локально на `127.0.0.1:8888`;
  на обычной машине — Docker/SearXNG или свой сервис.

## Throne

- На ISO не включён: вместо него Happ (Nix-пакет, легче). Этот раздел — если
  ставишь Throne на обычную машину вручную.
- Официальный GitHub-релиз, файл `Throne-<version>-linux-amd64.zip`
  (версию сверять с GitHub-релизом).
- Распаковать в `/opt/Throne`; `ThroneCore` должен быть setuid root для TUN
  (проверить `ls -l /opt/Throne/ThroneCore`).
- Nix-обёртка и polkit-правила — `host/programs/throne.nix`.
- Конфиг: `~/.config/Throne/config` (`throne.db`, `profiles/`).
  Бэкап — `~/.local/state/opencode/backups/throne-*`.
- Проверка: `command -v throne`; запуск на пустом столе; SOCKS/TUN — по
  настройкам Throne. Не держать одновременно с Amnezia/Happ TUN.

## AmneziaVPN

- На ISO `work`/`custom` официальный `.run` 5.1.0.6 распаковывается в `/opt`
  при активации; сервис и обёртка уже включены.
- На обычную машину — официальный `.run` в `/opt/AmneziaVPN`
  (шаги установщика; на хосте уже есть `common/vpn/amnezia-vpn.nix`).
- Юнит — `common/vpn/amnezia-vpn.nix`; обёртка `amnezia-vpn`.
  Юнит имеет `ConditionPathExists`, без `/opt` не падает.
- Конфиг: `~/.config/AmneziaVPN.ORG/AmneziaVPN.conf` (0600).
  Бэкап — `~/.local/state/opencode/backups/amnezia-*`.
- Проверка: `systemctl status AmneziaVPN`, `ip -br addr`, `ip route`.
  `active` ≠ туннель поднят.

## Happ

- На ISO `work`/`custom` включён `services.happ` (Nix-пакет 4.7.2); activation
  сам раскладывает его в `/opt/happ`, `happd` запускается.
- На хосте — ручной `/opt/happ` (`host/programs/happ.nix`), без Nix-модуля.
- На другой машине — `vendor/happ/module.nix` или официальный `.deb`.
- Проверка: `command -v happ`, `systemctl status happd`, `ip -br addr`.
- Не ставить одновременно два TUN-клиента к одному серверу.

## FreesmLauncher

- Nix-пакет из flake (`freesmlauncher`), `/opt` не нужен.
- Проверка: `command -v freesmlauncher`.

## Что не копировать

- `~/.cache`, `node_modules`, браузерные профили;
- `openclaw.json`, `auth.json`, `service.json`, `*.db` — живые секреты/БД;
- `/opt`-бинари в git; только рецепт + бэкап конфига.
