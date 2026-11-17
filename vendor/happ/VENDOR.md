# Happ: vendored

- Upstream: <https://github.com/MrShitFox/happ-nixos>
- В этом репозитории: `module.nix` (NixOS-модуль) и `package.nix` (пакет).
- Версия пакета: 4.7.2, официальный `.deb` Happ.
- Локальные изменения: `forceXwayland`/`forceSoftwareRendering`, обновлённая
  версия и hash; подробности — в комментариях `package.nix`.
- Лицензия: GPL-3.0 (`LICENSE`), отличается от Unlicense корневого репозитория.
- Где используется: только ISO (`iso/vpn.nix`). На хосте — ручной `/opt/happ`
  (`host/programs/happ.nix`).
- Обновление: менять версию/URL/hash в `package.nix`, затем собрать ISO.
  Не запускать два TUN-клиента одновременно.
