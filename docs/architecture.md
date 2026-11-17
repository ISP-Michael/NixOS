# Архитектура репозитория

Это один flake, но три разные системы:

| Система | Точка входа | Назначение |
|---|---|---|
| `MagicBook` | `host/default.nix` | обычная система на ноутбуке |
| `MagicBookInstall` | `host/default.nix` + `host/install.nix` | установка без sops |
| `iso-*` | `iso/default.nix` | live-система с профилями |

## Слои

```text
flake.nix
├── host/        только MagicBook; железо, диск, сервисы, пользователи
│   └── ../common/   переносимый системный слой
├── iso/         live-система; профили и рабочее окружение
│   └── ../common/   тот же переносимый слой
├── user/        Home Manager; один hub + домены
└── vendor/      сторонний код (Happ)
```

`common/` не знает про MagicBook и ISO. Всё, что зависит от `/dev/nvme0n1`,
sops-ключа хоста или конкретного пользователя, остаётся в `host/`.

## Дерево

```text
.
├── flake.nix                 # inputs, mkHost, mkIso, configs, packages
├── common/
│   ├── default.nix           # hub: только imports
│   ├── audio/pipewire.nix
│   ├── desktop/session.nix   # hyprland-session.target, окружение порталов
│   ├── hardware/
│   │   ├── bluetooth.nix
│   │   └── mtp.nix
│   ├── nix/
│   │   ├── cache.nix         # substituters, trusted keys
│   │   └── experimental-features.nix
│   ├── programs/
│   │   ├── appimage.nix
│   │   ├── dconf.nix
│   │   ├── nix-ld.nix
│   │   └── zsh.nix
│   ├── services/base.nix     # blueman, libinput, udisks2, gvfs, upower, PPD
│   ├── system/
│   │   ├── environment.nix   # GTK_USE_PORTAL, zshenv.local
│   │   ├── locale.nix
│   │   └── time.nix          # timezone + chrony (NTS off)
│   └── vpn/amnezia-vpn.nix   # юнит и обёртка /opt/AmneziaVPN
├── host/
│   ├── default.nix           # hub: common + домены
│   ├── home-manager.nix      # HM-обвязка, импортирует user/
│   ├── install.nix           # только для MagicBookInstall
│   ├── hardware/
│   │   ├── default.nix
│   │   ├── boot.nix
│   │   ├── disk.nix          # disko + fstrim = false
│   │   ├── fingerprint/      # Goodix + патчи
│   │   ├── hardware-configuration.nix
│   │   ├── kernel.nix        # bbr, ntsync, sysctl
│   │   ├── keyd/             # модуль + default.conf
│   │   └── swap.nix
│   ├── network/
│   │   ├── base.nix          # hostName, NM, IPv6
│   │   ├── firewall.nix      # LocalSend/QuickShare, virbr0
│   │   └── resolved.nix      # DoT/DNSSEC
│   ├── nix/
│   │   ├── daemon.nix        # Lix, build settings
│   │   ├── gc.nix            # optimise/gc + приоритеты
│   │   └── overlays.nix      # sphinx-hook workaround
│   ├── desktop/
│   │   ├── chromium.nix      # policy для темы Noctalia
│   │   ├── hyprland.nix      # Hyprland + KDE FileChooser
│   │   └── qt.nix            # KDE/Breeze
│   ├── packages/default.nix  # environment.systemPackages
│   ├── programs/
│   │   ├── defaults.nix      # direnv, steam, virt-manager, ydotool
│   │   ├── gamemode.nix
│   │   ├── happ.nix          # ручной /opt/happ
│   │   ├── npm.nix
│   │   └── throne.nix        # /opt/Throne + polkit
│   ├── security/
│   │   ├── sops.nix
│   │   └── ssh.nix
│   ├── services/
│   │   ├── flatpak.nix
│   │   ├── logind.nix
│   │   ├── qbittorrent.nix
│   │   ├── searxng/          # Docker + update.sh
│   │   └── virtualisation.nix
│   ├── system/
│   │   ├── documentation.nix
│   │   ├── fonts.nix
│   │   ├── journald.nix
│   │   ├── power.nix         # scx_bpfland
│   │   └── state.nix         # stateVersion
│   └── users/
│       ├── groups.nix
│       └── michael.nix
├── iso/
│   ├── default.nix           # hub: common + ISO-модули
│   ├── base.nix              # stateVersion, zram, ISO-настройки
│   ├── desktop.nix           # greetd + Hyprland + GTK-портал
│   ├── home.nix              # Home Manager для live
│   ├── networking.nix        # NM, без SSH
│   ├── nix.nix               # trusted-users, allowUnfree
│   ├── packages/             # opencode.nix, amnezia-vpn.nix
│   ├── profile-data.nix      # чистые флаги профилей
│   ├── profiles.nix          # пакеты профилей + option iso.profile
│   ├── repo.nix              # копия репо в /etc/nixos
│   ├── runtime.nix           # tun, npm, SearXNG
│   ├── users.nix             # live-пользователь Michael
│   ├── vpn.nix               # AmneziaVPN + Happ (только не-lite)
│   └── config/hypr/          # live-конфиг Hyprland
├── user/
│   ├── default.nix           # hub: base, dotfiles, packages, programs, theme, xdg
│   ├── base.nix              # имя, stateVersion, session vars, dconf
│   ├── xdg.nix               # XDG, mimeApps, userDirs, unciv.desktop
│   ├── packages/
│   │   ├── default.nix       # основной список
│   │   ├── overrides.nix     # zen, pywal16, telegram, neovide
│   │   └── python.nix        # python env + session-semantic
│   ├── programs/             # HM-модули
│   ├── theme/                # gtk/fonts/cursor + KDE-скрипт
│   └── dotfiles/             # живые конфиги → ~/.config
├── vendor/happ/              # сторонний Happ: module.nix + package.nix
├── secrets/                  # secrets.yaml, пример, restic (ignored)
├── assets/                   # картинки/обои; видео ignored
└── docs/
```

## Поток импортов

```text
flake.nix
  → host/default.nix
      → ../common/default.nix
      → host/{desktop,hardware,network,nix,packages,programs,security,services,system,users}
      → host/home-manager.nix
          → user/default.nix
              → user/{base,xdg,packages,programs,theme,dotfiles}

flake.nix
  → iso/default.nix
      → ../common/default.nix
      → iso/{base,nix,networking,users,profiles,desktop,runtime,home,repo}
      → iso/vpn.nix (если profile-data.vpn = true)
          → ../common/vpn/amnezia-vpn.nix
          → ../vendor/happ/module.nix
```

## Границы

- `common/` — можно использовать и хосту, и ISO. Никаких `Michael`, `/home/Michael`, `/dev/nvme0n1`, sops-путей.
- `host/` — можно всё, что относится к MagicBook. `home-manager.nix` — единственное место, где хост подключает `user/`.
- `iso/` — можно использовать `common/` и `vendor/`. Нельзя тянуть `host/`, кроме `common/vpn/amnezia-vpn.nix` (он уже в common).
- `user/` — Home Manager. Не знает, хост это или ISO; отличия задаются точкой входа (`host/home-manager.nix` или `iso/home.nix`).
- `vendor/` — не править без причины; локальные изменения фиксировать в `vendor/happ/README.md` или `docs/decisions.md`.

## Куда добавлять

| Задача | Куда |
|---|---|
| Новый пакет в систему | `host/packages/default.nix` |
| Новый пакет в пользователя | `user/packages/default.nix` |
| Новый NixOS-сервис | `host/services/<name>.nix` + импорт в `host/services/default.nix` |
| Новый `programs.*` | `host/programs/<name>.nix` + импорт в `host/programs/default.nix` |
| Новый пакет в ISO-профиль | `iso/profiles.nix` (списки `common/work/agent/...`) |
| Новый профиль ISO | `iso/profile-data.nix` + `iso/profiles.nix` + таблица в `docs/iso.md` |
| Новый общий модуль | `common/<домен>/<name>.nix` + импорт в `common/default.nix` |
| Новая тема/цвета | `user/theme/` |
| Новый dotfile | `user/dotfiles/.config/<app>` + список в `user/dotfiles/default.nix` |
| Новый секрет | `secrets/secrets.yaml` + `host/security/sops.nix` |
| Новая машина | свой `host/` (hardware + disko), не менять `MagicBook` |

## Живые конфиги

`user/dotfiles/.config/*` — не Nix-модули, а реальные файлы. `user/dotfiles/default.nix`
симлинкует их в `~/.config` при активации. Если каталог уже существует и это не
симлинк, он переименовывается в `.bak-<дата>`, а не удаляется.

Правило: если приложение управляется через `dotfiles`, не включай для него
HM-модуль с `settings` — они будут писать в один и тот же каталог.

## Секреты и крупные файлы

- `secrets/secrets.yaml` — зашифрован, можно коммитить.
- `secrets/apps.yaml` — необязательный зашифрованный снимок; в ISO не копируется.
- `secrets/opencode-restic/` — restic-репозиторий, gitignored, в ISO не копируется.
- `assets/videos/` — gitignored; в ISO не копируется.
- Приватные ключи, `auth.json`, `service.json`, `openclaw.json`, `*.db` — никогда в git.

## Проверка

```bash
cd /etc/nixos

# все конфигурации
for c in MagicBook MagicBookInstall iso-lite iso iso-custom iso-media iso-full; do
  nix eval --raw ".#nixosConfigurations.$c.config.system.build.toplevel.drvPath" >/dev/null \
    && echo "OK $c" || echo "FAIL $c"
done

# пакеты ISO
nix eval --raw .#packages.x86_64-linux.iso-custom.outPath >/dev/null && echo OK

# формат
nix fmt
```

Сборка ISO на 6 ГБ ОЗУ: `--max-jobs 1 --cores 1`, zstd 15 (уже в `iso/base.nix`).
Не запускать две тяжёлые сборки одновременно.
