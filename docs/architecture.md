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

Это карта слоёв, а не полный листинг: новые файлы могут появляться, не
меняя границ. Актуальный список — `fd -t f . | sort` или `git ls-files`.

```text
.
├── flake.nix                 # inputs, mkHost, mkIso, configs, packages
├── Makefile                  # check, ci, build-iso, switch, push, status
├── apps/
│   ├── README.md             # manual host vs pinned ISO
│   ├── amnezia/              # module.nix, package.nix, update.sh
│   ├── happ/                 # module.nix, update.sh
│   ├── opencode/             # package.nix, update.sh
│   ├── searxng/              # package.nix (upstream master)
│   └── throne/               # module.nix, update.sh
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
│   └── system/
│       ├── environment.nix   # GTK_USE_PORTAL, zshenv.local
│       ├── locale.nix
│       └── time.nix          # timezone + chrony (NTS off)
├── host/
│   ├── default.nix           # hub: common + домены
│   ├── identity.nix          # user, home, repoPath, hostName, diskDevice
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
│   │   ├── npm.nix
│   │   └── ../../apps/{happ,throne}/module.nix
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
│       └── primary.nix       # имя пользователя из host.identity
├── iso/
│   ├── default.nix           # hub: common + ISO-модули
│   ├── base.nix              # stateVersion, zram, ISO-настройки
│   ├── desktop.nix           # greetd + Hyprland + GTK-портал
│   ├── home.nix              # Home Manager для live
│   ├── networking.nix        # NM, без SSH
│   ├── nix.nix               # trusted-users, allowUnfree
│   ├── profile-data.nix      # чистые флаги профилей
│   ├── profiles.nix          # пакеты профилей + option iso.profile
│   ├── repo.nix              # копия репо в /etc/nixos
│   ├── runtime.nix           # tun, npm, SearXNG из apps/
│   ├── users.nix             # live-пользователь (iso.user)
│   ├── vpn.nix               # AmneziaVPN + Happ (только не-lite)
│   └── config/hypr/          # live-конфиг Hyprland
├── user/
│   ├── default.nix           # hub: base, dotfiles, packages, programs, theme, xdg
│   ├── base.nix              # identity, session vars, dconf
│   ├── xdg.nix               # XDG, mimeApps, userDirs, unciv.desktop
│   ├── packages/
│   │   ├── default.nix       # основной список
│   │   ├── overrides.nix     # zen, pywal16, telegram, neovide
│   │   └── python.nix        # python env + session-semantic
│   ├── programs/             # HM-модули
│   ├── theme/                # gtk/fonts/cursor + KDE-скрипт
│   └── dotfiles/             # живые конфиги → ~/.config
├── vendor/
│   ├── happ/                 # сторонний Happ: module.nix + package.nix
│   ├── tmux/                 # resurrect + continuum
│   └── zsh/                  # antidote
├── secrets/                  # secrets.yaml, пример; restic — в ~/Backups
├── assets/                   # картинки/обои; видео ignored
├── scripts/                  # ci.sh, deploy.sh, push.sh, status.sh
├── Makefile                  # удобные цели
├── AGENTS.md                 # правила для агента
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
          → ../apps/amnezia/module.nix
          → ../apps/happ/iso-module.nix
```

## Границы

- `common/` — можно использовать и хосту, и ISO. Никаких `Michael`, `/home/Michael`, `/dev/nvme0n1`, sops-путей.
- `host/hardware/hardware-configuration.nix`, `boot.nix` и `kernel.nix` —
  MagicBook/AMD; для другой машины заменить их и `host.diskDevice`.
- `host/` — можно всё, что относится к MagicBook. `home-manager.nix` — единственное место, где хост подключает `user/`.
- `iso/` — можно использовать `common/`, `vendor/` и `apps/`. Нельзя тянуть `host/`.
- `user/` — Home Manager. Не знает, хост это или ISO; отличия задаются точкой входа (`host/home-manager.nix` или `iso/home.nix`).
- `vendor/` — чужой код и вендоренные конфиги; локальные изменения фиксировать в README рядом или `docs/decisions.md`.

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
| Новое ручное/`/opt`-приложение | `apps/<name>/` + `module.nix`, `update.sh`, `README.md` |
| Новая машина/пользователь | `host/identity.nix`; hardware — свой `host/hardware` |
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

### nvim

`user/dotfiles/.config/nvim/init.lua` — bootstrap; `lua/pack.lua` — vim.pack;
`lua/core/` — editor primitives, `lua/plugins/` — plugin lifecycle, `lua/flat/`
— flatwhite/flatblack (sections in `lua/flat/theme/`). `colors/`,
`lua/lualine/themes/`, `after/` и `queries/` — fixed runtime paths. Подробности
и проверки — [`nvim.md`](nvim.md).

### Hyprland

`user/dotfiles/.config/hypr/` — вход хоста и общие модули; `iso/config/hypr/`
— вход live-ISO, live-профиль и live-автостарт. Общая композиция — в
`manifest.lua`, системные отличия — в `profile.lua` (ISO перекрывает его
через `package.path`). Правила, клавиши и опции разложены по `rules/`,
`binds/` и `settings/`; подробности — в [`hyprland.md`](hyprland.md).

### tmux

`user/dotfiles/.config/tmux/tmux.conf` — только hub из `source-file`:
`conf/options.conf`, `themes/mocha.conf`, `conf/statusline.conf`,
`conf/keys/*.conf`, `conf/session.conf`. Скрипты — `scripts/`, тема —
`themes/`; `themes/noctalia.conf` генерируется Noctalia и не коммитится.
Сторонние `tmux-resurrect` и `tmux-continuum` лежат в `vendor/tmux/`,
а `~/.config/tmux/vendor` — симлинк на него. Подробности — [`tmux.md`](tmux.md).

### zsh

`user/dotfiles/.config/zsh/.zshrc` — короткий вход; `manifest.zsh` грузит
`rc/{state,history,completion,plugins,integrations,keys,prompt,python}.zsh`.
Списки плагинов — `plugins/{completions,main,lazy}.txt`; antidote лежит в
`vendor/zsh/`, `~/.config/zsh/vendor` — симлинк. Сгенерированные compdump,
история и static-бандлы живут в XDG state/cache, не в репозитории.

### yazi

`yazi/yazi.toml` держит `[preview]`, `[tasks]` и `[plugin]`
preloaders/previewers; `keymap.toml` — пользовательские клавиши;
`init.lua` — кастомный header/separator; `package.toml` — managed-плагины
через `ya pkg`, `plugins/` — vendored-дерево. `theme.toml` остаётся одним
файлом (Yazi не умеет include); `flavors/noctalia.yazi` генерируется и
игнорируется. Подробности — [`yazi.md`](yazi.md).

### fastfetch

Один `config.jsonc`: identity → hardware → runtime; `break` вместо пустого
`custom`; добавлены battery/brightness/editor/localip/loadavg/processes/sound.
Новые возможности 2.70 (presets, `--gen-config`, `--structure`, JSON,
logo-протоколы) — в [`fastfetch.md`](fastfetch.md).

### kitty

`kitty.conf` — hub с `include conf.d/{colors,font,cursor,behavior,keys}.conf`.
`shell_integration disabled` (в 0.49 старое `no` невалидно), добавлены
scrollback, отключён audio bell, italic font features и `kitten hints`.
Подробности и новые возможности — [`kitty.md`](kitty.md).

## Секреты и крупные файлы

- `secrets/secrets.yaml` — зашифрован, можно коммитить.
- `secrets/apps.yaml` — необязательный зашифрованный снимок; в ISO не копируется.
- `~/Backups/opencode-restic/` — restic-репозиторий, вне git и вне ISO.
- `assets/videos/` — gitignored; в ISO не копируется.
- Приватные ключи, `auth.json`, `service.json`, `openclaw.json`, `*.db` — никогда в git.

## Проверка

```bash
cd /etc/nixos

# все конфигурации + пакеты
make check

# строгая проверка (чистое дерево)
make ci

# здоровье manual-частей
make status
```

Сборка ISO на 6 ГБ ОЗУ: `--max-jobs 1 --cores 1`, zstd 3 (уже в `iso/base.nix`).
Не запускать две тяжёлые сборки одновременно.
