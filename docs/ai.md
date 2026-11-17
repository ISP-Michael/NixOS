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
| OpenCode 2.3.0 | `iso/packages/opencode.nix` |
| AmneziaVPN `.run` | `iso/packages/amnezia-vpn.nix` |
| Happ | `vendor/happ/` |
| Живые dotfiles | `user/dotfiles/.config/` |
| Секреты | `secrets/secrets.yaml` |
| Документация | `docs/` |

## Команды

```bash
cd /etc/nixos

# проверить всё (быстро, без сборки)
for c in MagicBook MagicBookInstall iso-lite iso iso-custom iso-media iso-full; do
  nix eval --raw ".#nixosConfigurations.$c.config.system.build.toplevel.drvPath" >/dev/null \
    && echo "OK $c" || echo "FAIL $c"
done

# собрать ISO
nix build .#iso-custom -o result-iso-custom --max-jobs 1 --cores 1

# пересобрать хост (только по просьбе)
nixos-rebuild switch --flake .#MagicBook --sudo

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

`iso/packages/opencode.nix`: версия, URL npm-пакета, hash. Проверить
`opencode --version` (у npm-пакета может быть старый `--version`, это известно).

### Обновить Happ

`vendor/happ/package.nix`: версия, URL `.deb`, sha256. Локальные патчи —
в `vendor/happ/README.md` или `docs/decisions.md`.

## Грабли

- `xdg.desktopEntries` в текущем Home Manager сломан (`extraConfig` удалён).
  Для desktop-файлов использовать `xdg.dataFile."applications/<name>.desktop"`.
- `submaps.lua` удалён; ISO больше не делает `require('submaps')`. Print-
  сабмап со скриншотами сейчас не подключён. Вернуть можно из `dd6f314`.
- `user/dotfiles/default.nix` — живые симлинки. После переименования каталога
  старые ссылки становятся dangling; чинить `ln -sfn` на новый путь.
- `/etc/nixos` — жёстко зашитый путь в `user/dotfiles`, `iso/home.nix`,
  `iso/config/hypr`, `user/programs/nh.nix`, `user/programs/git.nix`,
  `user/dotfiles/.config/apps/*.sh`. Это ожидаемо для этой машины.
- ISO на 6 ГБ: zstd 15, `--max-jobs 1 --cores 1`; две сборки одновременно
  могут убить mksquashfs по памяти.
- `nix flake check` может быть тяжёлым; для быстрой проверки достаточно
  `nix eval` всех конфигураций.
- `secrets/opencode-restic/` — 700+ МБ, gitignored; не копировать в ISO.

## После большой правки

1. `git add -A` (иначе flake не увидит новые файлы).
2. Прогнать `nix eval` всех семи конфигураций.
3. Обновить `docs/architecture.md` и `docs/ai.md`, если менялись пути.
4. Записать факт в память: `~/.local/share/opencode/memory/topics/nixos-repo.md`,
   короткую запись — в journal.
5. Коммит — один понятный; чекпоинт до рефактора — `3192806`.
