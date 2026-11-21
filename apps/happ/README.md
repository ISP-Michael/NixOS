# Happ

Два независимых пути:

| Где | Как | Файлы |
|---|---|---|
| Хост | официальный `.deb` вручную в `/opt/happ` | `module.nix`, `update.sh` |
| Live-ISO | pinned Nix-пакет, `/opt/happ` раскладывается активацией | `package.nix`, `iso-module.nix` |

Хост не импортирует `package.nix`: по просьбе Happ ставится руками, обновление —
`sudo apps/happ/update.sh` (backup + распаковка `.deb` + рестарт `happd`).

ISO не может запустить `.deb`-установщик, поэтому там Nix-пакет. Он собран из
исходников upstream `MrShitFox/happ-nixos` (GPL-3.0, см. `LICENSE`), но
версия, hash и Qt-обходы теперь живут в этом каталоге, а не в `vendor/`.

## Обновление пакета для ISO

```bash
apps/happ/update-package.sh          # проверить, есть ли новая версия
apps/happ/update-package.sh --update # скачать, пересчитать hash, собрать .#happ
```

`--update` меняет `version` и `sha256` в `package.nix`, затем собирает
`nix build .#happ`. Если сборка падает — файл откатывается. После успешной
сборки проверь новые зависимости/патчи и собери ISO.

Автоматизация через агента: раз в неделю запускать `--check`; при новой
версии — `--update`, затем `nix build .#iso-custom` и smoke-test. Автоматически
коммитить нельзя: новые зависимости и Qt-поведение надо смотреть глазами.

## Проверка

```bash
command -v happ
systemctl status happd
ip -br addr
```

Конфиг: `~/.config/Happ`. Не запускать два TUN-клиента одновременно
(AmneziaWG/Throne/Happ).
