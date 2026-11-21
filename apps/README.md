# Приложения вне Nix store

Здесь лежат приложения, которые на хосте ставятся официальными установщиками
в `/opt` или `~/.local`, а в ISO — из pinned-пакета Nix store.

Правило: **интеграция** (обёртка, systemd, desktop, firewall) — в `module.nix`;
**установка/обновление** — в `update.sh`; версия и ограничения — в `README.md`.

| Приложение | Host | ISO |
|---|---|---|
| `amnezia` | официальный `.run` в `/opt/AmneziaVPN`, `update.sh` | pinned `.run` из store, activation |
| `happ` | официальный `.deb` в `/opt/happ`, `update.sh` | `apps/happ/package.nix` + `iso-module.nix` |
| `throne` | официальный zip в `/opt/Throne`, `update.sh` | не входит |
| `opencode` | официальный установщик в `~/.opencode`, `update.sh` | pinned npm tarball |
| `searxng` | Docker `searxng/searxng:latest` | upstream source pinned в store |

Host-режим сознательно «latest manual»; ISO-режим — «pinned offline».
Не смешивать: не тащить host-бинарники в Nix и не ставить ISO-пакеты в `/opt`
без необходимости.
