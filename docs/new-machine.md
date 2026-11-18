# Новая машина

Сейчас `host/` — это MagicBook. Для другой машины не меняй его «на месте»:
сделай копию и замени hardware-часть.

## 1. Идентичность

В `host/identity.nix` (или в копии) задай:

- `user`, `home` — основной пользователь;
- `repoPath` — путь к репозиторию (обычно `/etc/nixos`);
- `hostName`;
- `diskDevice` — диск для disko;
- `gitName`, `gitEmail`.

ISO-часть: `iso.user`, `iso.hostName` в `iso/users.nix`/`iso/networking.nix`.

## 2. Железо

```bash
sudo nixos-generate-config --root /mnt
```

Замени `host/hardware/hardware-configuration.nix` на сгенерированный.
`host/hardware/boot.nix` и `kernel.nix` содержат AMD-параметры MagicBook —
проверь и убери лишнее. `host/hardware/disk.nix` — disko-разметка; для другой
машины нужен свой диск/разметка.

## 3. Flake

Добавь конфигурацию в `flake.nix`:

```nix
configs = {
  MagicBook = mkHost [ ];
  NewMachine = mkHost [ ]; # или свой extraModules
  # ...
};
```

Если hardware-файлы лежат в отдельном каталоге, импортируй его через
`extraModules` или сделай отдельный `hosts/<name>/`.

## 4. Sops

См. `docs/secrets.md`. Кратко:

1. Сгенерируй host-ключ новой машины.
2. `ssh-to-age` → добавь в `.sops.yaml` на машине с admin-ключом.
3. `sops updatekeys secrets/secrets.yaml`.
4. Ставь `#NewMachine` (если host-ключ уже есть) или `#MagicBookInstall`
   как bootstrap без sops, затем пересобери.

## 5. Проверка

```bash
nix eval --raw .#nixosConfigurations.NewMachine.config.system.build.toplevel.drvPath
nixos-rebuild build --flake .#NewMachine
```

Не запускай `disko`/`nixos-install` на чужом диске без бэкапа.
