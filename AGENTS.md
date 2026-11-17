# AGENTS.md

Правила для ИИ-агента, который работает с этим репозиторием. Если ты не
помнишь прошлых сессий — сначала прочитай `docs/ai.md` и
`docs/architecture.md`, потом `docs/conventions.md`.

## Что это

Один NixOS-флейк в `/etc/nixos`:

- `MagicBook` — система на ноутбуке;
- `MagicBookInstall` — установка без sops;
- `iso-*` — live-ISO.

`common/` — переносимое, `host/` — только этот ноутбук, `iso/` — live,
`user/` — Home Manager, `vendor/` — стороннее.

## Перед работой

```bash
cd /etc/nixos
git status --short
git log --oneline -3
```

Чекпоинт до крупного рефактора — `3192806`. Если работа может затянуться,
предупреди и не запускай пересборку/установку без явной просьбы.

## Команды

```bash
# проверить все конфигурации
for c in MagicBook MagicBookInstall iso-lite iso iso-custom iso-media iso-full; do
  nix eval --raw ".#nixosConfigurations.$c.config.system.build.toplevel.drvPath" >/dev/null \
    && echo "OK $c" || echo "FAIL $c"
done

# ISO
nix build .#iso-custom -o result-iso-custom --max-jobs 1 --cores 1

# хост (только по просьбе)
nixos-rebuild switch --flake .#MagicBook --sudo

# формат (по желанию; может затронуть legacy-файлы)
nix fmt
```

Флейк использует `git+file:///etc/nixos`: новые файлы должны быть
`git add`-нуты, иначе `nix eval` их не увидит.

## Запреты

- Не печатать и не коммитить секреты; `secrets/secrets.yaml` — только
  зашифрованным. Не копировать приватные ключи.
- Не менять `host/hardware/keyd/default.conf` без `keyd check` на копии.
- Не добавлять Flatpak-приложения без явной просьбы.
- Не трогать `host/hardware/hardware-configuration.nix` и `disk.nix` для
  другой машины — для неё нужен свой host.
- Не запускать `disko`, `dd`, `sops updatekeys`, `nixos-rebuild switch`
  без явной просьбы.
- Не открывать GUI на активном столе; использовать пустой стол и
  `workspace = "N silent"`.
- Не тащить в ISO Steam, Blender, Docker, виртуалки.

## Стиль

- Nix — вертикально, один атрибут на строку, списки по элементу.
- `default.nix` — только `imports`; листья не импортируют листья.
- Имя файла = предмет/корень опции, не `settings.nix`/`services.nix`
  внутри одноимённого каталога.
- Комментарий объясняет «почему», а не пересказывает код.
- Выключенное — в `docs/decisions.md`, не в живом дереве.

## После правки

1. `git add -A`.
2. Прогнать `nix eval` всех семи конфигураций.
3. Обновить `docs/architecture.md`/`docs/ai.md`, если менялись пути.
4. Записать факт в память: `~/.local/share/opencode/memory/topics/nixos-repo.md`,
   короткую запись — в journal.
5. Коммит — один понятный; тело — что переименовано/удалено.
