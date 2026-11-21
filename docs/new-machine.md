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

1. На новой машине получить публичный age-ключ host:

   ```bash
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```

2. Добавить его в `.sops.yaml` рядом с остальными получателями:

   ```yaml
   keys:
     - &admin_user age1q7...
     - &host_magicbook age1735...
     - &host_new age1...
   creation_rules:
     - path_regex: secrets/[^/]+\.(yaml|json|env|ini)$
       key_groups:
         - pgp: []
           age:
             - *admin_user
             - *host_magicbook
             - *host_new
   ```

3. На машине, которая может расшифровать (MagicBook), перешифровать секреты:

   ```bash
   sudo SOPS_AGE_KEY_FILE=/run/secrets-for-users.d/age-keys.txt \
     SOPS_CONFIG=/etc/nixos/.sops.yaml \
     sops updatekeys --yes /etc/nixos/secrets/secrets.yaml
   ```

   Для `secrets/apps.yaml`, если он есть, — то же самое.

4. Закоммитить `.sops.yaml` и перешифрованные файлы. Приватный ключ никуда
   не копируется: новая машина расшифрует своим host-ключом.

Если новая машина ещё не может загрузиться из-за sops (курица и яйцо),
сначала поставь `#MagicBookInstall` — ту же систему без sops и с временным
паролем `nixos`, — загрузи её, добавь host-ключ, сделай `updatekeys` и
переключись на полный профиль.

Теория sops, admin-ключ и восстановление — `docs/secrets.md`.

## 5. Проверка

```bash
nix eval --raw .#nixosConfigurations.NewMachine.config.system.build.toplevel.drvPath
nixos-rebuild build --flake .#NewMachine
```

Не запускай `disko`/`nixos-install` на чужом диске без бэкапа.
