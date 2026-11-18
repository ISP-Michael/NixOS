# AI context pack

Этот файл — короткая выжимка для агента, который не помнит прошлых сессий.
Сначала прочитай его и `docs/architecture.md`; остальные документы — по теме.

## Что это

Личный NixOS-флейк в `/etc/nixos`:

- `MagicBook` — система на ноутбуке Huawei BOHK-WAX9X;
- `MagicBookInstall` — установка без sops;
- `iso-lite`, `iso`, `iso-custom`, `iso-media`, `iso-full` — live-ISO.

Главный принцип: `common/` — переносимое, `host/` — только этот ноутбук,
`iso/` — live, `user/` — Home Manager, `vendor/` — стороннее.

## Ключевые пути

| Что | Путь |
|---|---|
| Вход хоста | `host/default.nix` |
| Вход ISO | `iso/default.nix` |
| Вход Home Manager | `user/default.nix` |
| Профили ISO | `iso/profiles.nix` + `iso/profile-data.nix` |
| Пакеты ISO | `iso/profiles.nix` |
| OpenCode 2.3.0 (ISO) | `apps/opencode/package.nix` |
| AmneziaVPN `.run` | `apps/amnezia/package.nix` + `apps/amnezia/module.nix` |
| Happ | `apps/happ/module.nix` (host), `vendor/happ/` (ISO) |
| Прокси/ручные apps | `apps/*/update.sh` + `README.md` |
| Живые dotfiles | `user/dotfiles/.config/` |
| Секреты | `secrets/secrets.yaml` |
| Документация | `docs/` |
| CI/деплой | `scripts/ci.sh`, `scripts/deploy.sh`, `scripts/push.sh`, `Makefile` |
| Идентичность | `host/identity.nix` |

## Команды

```bash
cd /etc/nixos

# проверить всё (быстро, без сборки)
make check

# строгая проверка (нужно чистое дерево)
make ci

# собрать ISO
make build-iso

# пересобрать хост (только по просьбе)
make switch

# здоровье manual-частей
make status

# формат (по желанию; может затронуть legacy-файлы)
nix fmt
```

`flake.nix` использует `git+file:///etc/nixos`: новые файлы должны быть
`git add`-нуты, иначе `nix eval` их не увидит.

## Инварианты

- **Секреты:** не печатать, не коммитить plaintext, не копировать приватные
  ключи. `secrets/secrets.yaml` — только зашифрованным.
- **keyd:** не менять `host/hardware/keyd/default.conf` без `keyd check` на
  копии. Пользователь отказался от переделки слоёв.
- **Flatpak:** не добавлять новые Flatpak-приложения без явной просьбы.
- **Железо:** `host/hardware/hardware-configuration.nix` и `disk.nix` —
  только MagicBook (`/dev/nvme0n1`). Для другой машины нужен свой host.
- **MagicBookInstall:** не нужен для `nix build`; только для установки без
  sops-ключа. Пароль `nixos` — временный.
- **ISO:** не тащить Steam, Blender, Docker, виртуалки. Docker — после
  установки, с интернетом.
- **Экран:** не открывать GUI на активном столе; использовать пустой стол и
  `workspace = "N silent"`.
- **Пересборка:** `cd /etc/nixos && nixos-rebuild switch --flake .#MagicBook --sudo`,
  не `sudo nixos-rebuild`.

## Частые задачи

### Добавить пакет в хост

`host/packages/default.nix` → `environment.systemPackages`.

### Добавить пакет в пользователя

`user/packages/default.nix` (или `overrides.nix`, если нужна своя сборка).

### Добавить сервис

`host/services/<name>.nix` → импорт в `host/services/default.nix`.
Если сервис нужен и ISO — `common/` + импорт в `common/default.nix`.

### Добавить профиль ISO

1. `iso/profile-data.nix` — флаги `agent`/`vpn`;
2. `iso/profiles.nix` — список пакетов и описание;
3. `flake.nix` — `iso-<name> = mkIso "<name>"`;
4. `docs/iso.md` — таблица.

### Обновить OpenCode

ISO: `apps/opencode/package.nix` — версия, URL npm-пакета, hash.
Host: `apps/opencode/update.sh` (он же `opencode-update.timer`), обновляет
`~/.opencode/bin/opencode`. Проверить `opencode --version`.

### Обновить Happ

`vendor/happ/package.nix`: версия, URL `.deb`, sha256. Локальные патчи —
в `vendor/happ/README.md` или `docs/decisions.md`.

## Грабли

- `xdg.desktopEntries` в текущем Home Manager сломан (`extraConfig` удалён).
  Для desktop-файлов использовать `xdg.dataFile."applications/<name>.desktop"`.
- Hyprland: общие модули перечислены в
  `user/dotfiles/.config/hypr/manifest.lua`; системные отличия — в
  `profile.lua` (ISO перекрывает его через `package.path`). Новый общий
  файл добавлять в manifest, хостовые пути — только в `profile.lua`.
  Проверка: `make hypr-check` или `Hyprland --verify-config -c ...`.
- На 6 ГБ `make check`/`make ci` — только при закрытых Firefox/Electron/
  OpenClaw: полный `nix eval` уходит в swap и может задушить композитор.
  Для правок Hyprland достаточно `make hypr-check`.
- `nix-daemon` ограничен `CPUWeight=20`, `IOWeight=50`, `MemoryHigh=3G`
  (`host/nix/daemon.nix`), чтобы сборки не вытесняли композитор в своп.
  `make switch`/`build` больше не запускают полный `ci.sh` — только чистое
  дерево и `git diff --check`; полный eval остаётся в `make ci`/`make push`.
- `submaps.lua` удалён; ISO больше не делает `require('submaps')`. Print-
  сабмап со скриншотами сейчас не подключён. Вернуть можно из `dd6f314`.
- `user/dotfiles/default.nix` — живые симлинки. После переименования каталога
  старые ссылки становятся dangling; чинить `ln -sfn` на новый путь.
- `~/.config/{yazi,tmux}` — симлинки в репозиторий, поэтому Noctalia пишет туда
  свои выходы: `yazi/flavors/noctalia.yazi/*` и `tmux/themes/noctalia.conf`.
  Это не исходники, а рендер палитры обоев (community-шаблоны `yazi` и `tmux`),
  они в `.gitignore`; после смены обоев их не коммитить. `yazi/theme.toml` —
  наоборот, ручная база, её правит только post-hook (`[flavor]`), она в git.
- tmux: `tmux.conf` — только `source-file`-hub; листья в `conf/`, скрипты в
  `scripts/`, fallback-тема в `themes/mocha.conf`. `vendor/` — симлинк на
  `vendor/tmux` (resurrect/continuum); TPM/catppuccin/tmux-yank удалены как
  неиспользуемые. `prefix r` аддитивен — для проверки refactor'а поднимать
  свежий сервер `tmux -L test`. `~/.config/systemd/user/tmux.service`
  генерирует continuum; при переносе vendor путь `ExecStop` надо обновить.
- zsh: `ZDOTDIR=~/.config/zsh`, `.zshrc` -> `manifest.zsh` -> `rc/*.zsh`;
  плагины — `plugins/{completions,main,lazy}.txt`, antidote в `vendor/zsh`
  через симлинк. `compinit` пишет в `~/.local/state/zsh/zcompdump`, static
  бандлы — в `~/.cache/antidote/static`; сгенерированное в git не держать.
  Проверка: `make zsh-check`. `starship.toml` генерирует Noctalia.
- `/etc/nixos` — путь по умолчанию в `host/identity.nix`; HM получает
  `identity.repoPath`. Live-путь `/etc/nixos` жёстко зашит в
  `iso/config/hypr/hyprland.lua`, потому что ISO всегда копируется туда.
- ISO на 6 ГБ: zstd 3, `--max-jobs 1 --cores 1`; две сборки одновременно
  могут убить mksquashfs по памяти. zstd 15 собирался ~10 мин и уводил
  систему в своп рядом с игрой.
- `nix flake check` может быть тяжёлым; для быстрой проверки достаточно
  `make check`.
- `~/Backups/opencode-restic/` — 700+ МБ, вне git; не копировать в ISO.
- `usque` удалён 18.11.2026: не использовался, SearXNG работает без прокси.
- `opencode-update.timer` теперь в репозитории:
  `user/dotfiles/.config/opencode/systemd/user/`.
- `Noctalia 5.5.0` патчится под fingerprint и собирается из исходников
  (кэш невозможен из-за патча); после первой сборки локальный store
  переиспользуется.

## После большой правки

1. `git add -A` (иначе flake не увидит новые файлы).
2. Прогнать `nix eval` всех семи конфигураций.
3. Обновить `docs/architecture.md` и `docs/ai.md`, если менялись пути.
4. Записать факт в память: `~/.local/share/opencode/memory/topics/nixos-repo.md`,
   короткую запись — в journal.
5. Коммит — один понятный; чекпоинт до рефактора — `3192806`.
