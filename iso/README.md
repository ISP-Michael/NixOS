# ISO

Live-система NixOS с Hyprland, собранная из этого же флейка. Это не
установщик «нажми одну кнопку», а нормальная live-система: с неё можно
работать, а репозиторий конфига лежит внутри.

## Профили

Набор пакетов задаётся опцией `iso.profile` в `iso/packages.nix`.
В `flake.nix` уже есть пять выходов:

| Конфигурация | Что внутри | Ориентир по размеру ISO |
|---|---|---|
| `iso-lite` | Hyprland, Firefox, Thunar, mpv, zathura, CLI, тема, portable runtime | ~4 ГБ |
| `iso` (work) | + LibreOffice, Telegram, KeePassXC, CopyQ, OpenCode, AmneziaVPN + Happ, агентский runtime | ~5 ГБ |
| `iso-custom` | lite + LibreOffice, Telegram, KeePassXC, Pandoc, OpenCode, AmneziaVPN + Happ, агентский runtime | **4.6 ГБ** (собран 17.11.2026) |
| `iso-media` | work + GIMP, OBS, VLC, Dolphin/Okular/Ark | ~6.5 ГБ |
| `iso-full` | + Python/Node/GCC/Go/Rust/.NET, Obsidian, Bitwarden, Thunderbird | ~9 ГБ |

Размеры — по closure в Nix store; squashfs сжимает примерно вдвое.
Точный размер видно после сборки.

## Сборка

```bash
cd /etc/nixos
nix build .#iso-custom -o result-iso-custom
# или .#iso-lite / .#iso / .#iso-media / .#iso-full
```

Эквивалент полного пути:
`nix build .#nixosConfigurations.iso-custom.config.system.build.isoImage`.

Готовый файл:

```bash
ls -lh result-iso-custom/iso/*.iso
```

## Запись на флешку

Сначала посмотреть, какое устройство флешка, и не перепутать с диском:

```bash
lsblk -o NAME,SIZE,MODEL,MOUNTPOINTS
```

Потом (пример для `/dev/sdX`, подставить своё):

```bash
sudo dd if=result-iso-custom/iso/*.iso of=/dev/sdX bs=4M status=progress oflag=sync
sync
```

## Что внутри live-системы

- Пользователь `Michael`, пароля нет, вход в Hyprland автоматический.
- `sudo` без пароля (как в обычном установщике NixOS).
- Сеть — NetworkManager: `nmtui` в терминале или апплет в баре.
- Звук — PipeWire, яркость/громкость — на клавишах, как в хостовом конфиге.
- Конфиги Hyprland/kitty/nvim/tmux/zsh/yazi лежат в `/etc/nixos` и
  подключаются в `~/.config`; сам Hyprland использует live-вариант
  `iso/config/hypr`, чтобы не запускать отсутствующие приложения.
- Браузер — только Firefox. Chromium стоит как зависимость OpenCode
  (Playwright MCP), а не как второй браузер.
- OpenCode 2.3.0 (официальный релиз) и AmneziaVPN 5.1.0.6 + Happ уже
  в `work`/`custom`/`media`/`full`; Throne не включён.

## VPN, OpenCode и OpenClaw

В `work`/`custom`/`media`/`full` уже есть:

- **OpenCode 2.3.0** — официальный релиз, не сломанный nixpkgs-пакет;
- **AmneziaVPN 5.1.0.6** — официальный `.run` распаковывается в `/opt` при
  активации; сервис и обёртка `amnezia-vpn` из `host/services/amnezia-vpn-service.nix`;
- **Happ 4.7.2** — Nix-пакет, `happd`, TUN; принудительно XWayland, потому
  что встроенный Qt-Wayland падает на Hyprland.

Throne не включён: Happ легче и уже есть как Nix-пакет. Два TUN-клиента
одновременно не запускать — Amnezia/Happ конфликтуют так же, как
Amnezia/Throne.

OpenClaw — по-прежнему ручная установка Node/npm: `install.sh` ставит
конфиги и unit-файлы, но не сам бинарь. Подробности —
`user/scripts/.config/apps/TRANSFER.md` и `MANUAL-APPS.md`.
`searxng` для поиска агентов поднимается локально на `127.0.0.1:8888`
в `work`/`custom`/`media`/`full` (в `iso-lite` его нет).

Chromium нужен Playwright MCP из `opencode.jsonc`, Node/Python — плагинам
и `openclaw-maintenance.py`, restic/sqlite — бэкапу сессий.

## Ключи sops

Системный пароль и `secrets/apps.yaml` расшифровываются sops. Сборка
(`nix build`/`nixos-rebuild build`) ключ не требует, активация/установка —
требует. `.sops.yaml` и `secrets/secrets.yaml` синхронизированы 17.11.2026:
получатели — старый admin, текущий admin и host MagicBook. Новым машинам
добавлять свой host-ключ в `.sops.yaml` и делать `sops updatekeys`; подробно —
[`../secrets/KEYS.md`](../secrets/KEYS.md).

`MagicBookInstall` — временный установочный профиль без sops и с паролем
`nixos`. Он нужен только чтобы поставить/загрузить систему без ключа; после
этого добавляешь host-ключ и пересобираешь `#MagicBook`. Для обычного
`nix build`/`rebuild` он не нужен.

## Репозиторий внутри ISO

При загрузке activation-скрипт копирует исходники флейка в `/etc/nixos`.
Это обычная копия без `.git` (историю не таскаем — она тяжёлая).
Можно править и собирать:

```bash
cd /etc/nixos
nix build .#nixosConfigurations.iso-lite.config.system.build.isoImage
```

`nixos-rebuild switch` на live-системе тоже возможен (store — overlay
в tmpfs), но он меняет именно live-систему. Для установки на диск это
не нужно: там используется `#MagicBook`.

Важно: `/` и `/etc` на live-системе — tmpfs. После перезагрузки правки
пропадут. Если нужно сохранить — скопируй `/etc/nixos` на диск/флешку.

Если правишь `iso/` перед сборкой, не забудь `git add`: flake-исходники
не видят untracked-файлы.

## Установка на диск

Это отдельный и **разрушительный** шаг; делать только осознанно.

Для MagicBook разметка уже описана в `host/disko.nix` (`/dev/nvme0n1`,
LUKS + btrfs). Проверить диск:

```bash
lsblk -o NAME,SIZE,MODEL
```

Дальше — только если это действительно нужный диск:

```bash
sudo disko --mode destroy,format,mount --flake /etc/nixos#MagicBook
sudo nixos-install --flake /etc/nixos#MagicBook
```

Но у `MagicBook` пароль пользователя берётся из sops-секрета
(`secrets/secrets.yaml`). Без ключа, который может его расшифровать,
установка не соберётся. Подробная инструкция — [`../secrets/KEYS.md`](../secrets/KEYS.md).
Коротко:

1. добавить host-ключ новой машины в `.sops.yaml` и сделать `sops updatekeys`;
2. или держать admin age-ключ и передать его установщику;
3. или поставить `#MagicBookInstall` (без sops, пароль `nixos`), загрузиться,
   добавить host-ключ и пересобрать `#MagicBook`.

Пример для варианта 3:
```bash
sudo disko --mode destroy,format,mount --flake /etc/nixos#MagicBookInstall
sudo nixos-install --flake /etc/nixos#MagicBookInstall
sudo cp -a /etc/nixos /mnt/etc/nixos
```

Для другой машины `host/disko.nix` и `host/hardware-configuration.nix`
не подходят: там нужен `nixos-generate-config` и своя разметка.

## Что не влезло

Steam, Blender, Docker, виртуалки и прочее тяжёлое специально не тащим.
Docker в live-системе без интернета смысла не имеет; на установленной
системе его можно включить позже. Throne не включён (Happ вместо него),
Obsidian/Bitwarden/Thunderbird остаются в `full`. OpenClaw ставится вручную.
После установки весь хостовый набор ставится из репозитория `#MagicBook`.
