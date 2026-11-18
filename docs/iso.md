# Live-ISO

Live-система NixOS с Hyprland, собранная из этого же флейка. Это не
«установщик в одну кнопку»: с неё можно работать, а репозиторий конфига
лежит внутри.

## Профили

Профили задаются в `iso/profile-data.nix` (флаги) и `iso/profiles.nix`
(пакеты). `flake.nix` создаёт конфигурации `iso-lite`, `iso` (work),
`iso-custom`, `iso-media`, `iso-full`.

| Конфигурация | Что внутри | Размер |
|---|---|---|
| `iso-lite` | Hyprland, Firefox, Thunar, mpv, zathura, CLI, portable runtime | точный — после сборки |
| `iso` (work) | lite + LibreOffice, Telegram, KeePassXC, CopyQ, OpenCode, AmneziaVPN + Happ | точный — после сборки |
| `iso-custom` | lite + LibreOffice, Telegram, KeePassXC, Pandoc, OpenCode, AmneziaVPN + Happ | **4.8 ГБ** (18.11.2026, zstd 3) |
| `iso-media` | work + GIMP, OBS, VLC, Dolphin/Okular/Ark | точный — после сборки |
| `iso-full` | + Python/Node/GCC/Go/Rust/.NET, Obsidian, Bitwarden, Thunderbird | точный — после сборки |

`lite` не получает агентский runtime (OpenCode, Node, Python, Chromium,
SearXNG) и VPN-модуль. `work`/`custom`/`media`/`full` получают.
Текущий `iso-custom` собран 18.11.2026 с Noctalia 5.5.0 и SearXNG master.
Предыдущая сборка на zstd 15 весила 4.6 ГБ; zstd 3 прибавил ~0.2 ГБ.

## Сборка

```bash
cd /etc/nixos
nix build .#iso-custom -o result-iso-custom --max-jobs 1 --cores 1
# или .#iso-lite / .#iso / .#iso-media / .#iso-full
```

На 6 ГБ ОЗУ не запускать две тяжёлые сборки одновременно. В `iso/base.nix`
стоит `zstd -Xcompression-level 3`: слабое сжатие, зато `mksquashfs` не
занимает память и не молотит своп. zstd 15 давал образ меньше, но собирался
в разы дольше и ронял отзывчивость.

Результат:

```bash
ls -lh result-iso-custom/iso/*.iso
```

Запись на флешку:

```bash
sudo dd if=result-iso-custom/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Установка

Обычный путь — с live-системы, репозиторий уже в `/etc/nixos`:

```bash
sudo disko --mode destroy,format,mount --flake /etc/nixos#MagicBook
sudo nixos-install --flake /etc/nixos#MagicBook
```

Но `MagicBook` берёт пароль пользователя из sops. Без ключа, который может
расшифровать `secrets/secrets.yaml`, установка упрётся в активацию. Варианты:

1. добавить host-ключ новой машины в `.sops.yaml` и сделать `sops updatekeys`;
2. держать admin age-ключ и передать его установщику;
3. поставить `#MagicBookInstall` — без sops, с временным паролем `nixos`.

Пример для варианта 3:

```bash
sudo disko --mode destroy,format,mount --flake /etc/nixos#MagicBookInstall
sudo nixos-install --flake /etc/nixos#MagicBookInstall
sudo cp -a /etc/nixos /mnt/etc/nixos
```

После загрузки добавить host-ключ, пересобрать `#MagicBook` и сменить пароль.
`MagicBookInstall` не нужен для `nix build`/`nixos-rebuild build`; это только
установочный профиль.

`host/hardware/hardware-configuration.nix` и `host/hardware/disk.nix` —
MagicBook (`/dev/nvme0n1`). Для другой машины нужен свой host и
`nixos-generate-config`.

## Что на live

- Пользователь `Michael` (`iso.user`), greetd-автологин в Hyprland, Noctalia 5.5.0 (патч fingerprint) + `user/theme`.
- Имя live-системы — `iso.hostName` (по умолчанию `nixos-live`).
- В меню только **Firefox**. Chromium — обёртка `chromium` для Playwright MCP
  OpenCode, без desktop-файла.
- В `work`/`custom`/`media`/`full`: OpenCode 2.3.0 (`apps/opencode/package.nix`),
  AmneziaVPN 5.1.0.6 (`apps/amnezia/package.nix`, `.run` распаковывается в `/opt`),
  Happ 4.7.2 (`vendor/happ`), Node 26, Python 3, restic, sqlite,
  SearXNG из `apps/searxng/package.nix` (upstream master pinned) на `127.0.0.1:8888`.
- Throne, Steam, Blender, Docker, виртуалки не включены.
- SSH выключен: у live-пользователя пустой пароль, открытый порт не нужен.
- chrony включён через `common/system/time.nix`; NTS выключен намеренно.
- Qt без `qt5ct`/`kvantum`: только `qt.enable = true`, чтобы Telegram и
  другие Qt-приложения видели плагины.

## Репозиторий внутри ISO

`iso/repo.nix` копирует `self` в `/etc/nixos` при активации, если там ещё нет
`flake.nix`. Исключаются `.git`, `result*`, `secrets/opencode-restic`
(старый путь-страховка), `secrets/apps.yaml`, `assets/videos`. После установки репозиторий можно
скопировать на диск и пересобирать уже там.

## Живые конфиги

Hyprland на live использует `iso/config/hypr`: собственный вход,
`profile.lua` и `autostart.lua`. Общие модули (`manifest.lua`, `settings/`,
`binds/`, `rules/`) берутся из `user/dotfiles/.config/hypr`; ISO-вход ставит
свой каталог первым в `package.path`, поэтому host-профиль и host-автостарт
с Zen, Telegram, Obsidian и Lutris не подхватываются. Остальные конфиги
(kitty, nvim, tmux, zsh, yazi, fastfetch) — из `user/dotfiles/.config` через
`iso/home.nix`. tmux стартует с tracked fallback-темой `themes/mocha.conf`;
`themes/noctalia.conf` появится только после первого рендера Noctalia.

`submaps.lua` удалён; ISO не делает `require('submaps')`. Print-сабмап со
скриншотами сейчас не подключён; вернуть можно из `dd6f314`.

## Sops

Подробно — [`secrets.md`](secrets.md). Коротко: сборка ключ не требует;
активация/установка — требует. `.sops.yaml` и `secrets/secrets.yaml`
синхронизированы 17.11.2026 (старый admin, текущий admin, host MagicBook).
`MagicBookInstall` — только для установки без ключа.

## Проверка перед записью

```bash
cd /etc/nixos
nix eval --raw .#nixosConfigurations.iso-custom.config.system.build.toplevel.drvPath
nix eval --raw .#packages.x86_64-linux.iso-custom.outPath
file result-iso-custom/iso/*.iso
```

`file` должен сказать `ISO 9660 ... (bootable)`.
