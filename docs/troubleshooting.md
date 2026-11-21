# Если что-то сломалось

Короткий справочник: симптом → причина → что делать. Если проблема не тут,
смотри профильные документы (`iso.md`, `secrets.md`, `hyprland.md`).

## Проверки и сборки

**`make switch` пишет `working tree is dirty`.**

Есть незакоммиченные изменения. Закоммить их или, осознанно,
`ALLOW_DIRTY=1 make switch`. Для `make check` грязное дерево разрешено.

**`make check`/`ci`/`build-iso` отказываются стартовать: `game is running`.**

Сработал `scripts/guard-gaming.sh`: запущены Proton/Lutris/gamescope или
известная игра. Дождись выхода из игры; обход — `ALLOW_GAMING=1`.

**`make ci` или `nix eval` подвешивает интерфейс.**

Полный `ci` вычисляет 7 конфигураций и 5 ISO — на 6 ГБ это не для
повседневного запуска. Локально достаточно `make check`; полный прогон
делает GitHub Actions. Не возвращай `builtins.getFlake (toString /etc/nixos)`:
path-флейк копирует весь каталог в store и уводит машину в своп.

**`git diff --check` падает.**

В изменениях trailing whitespace или конфликтные маркеры. Посмотри
`git diff --check` и поправь строки.

## Hyprland и Noctalia

**Пропал бар Noctalia, окна есть.**

```bash
systemctl --user is-active noctalia.service
systemctl --user show-environment | rg WAYLAND
```

Если `WAYLAND_DISPLAY` указывает на несуществующий сокет (например,
`wayland-3` после вложенного композитора или перезапуска сессии) — Noctalia
не стартует:

```bash
systemctl --user set-environment WAYLAND_DISPLAY=wayland-1
systemctl --user restart noctalia.service
```

Актуальный сокет — `ls /run/user/1000/wayland-*`, актуальная подпись —
`hyprctl instances -j`.

**Чёрный экран после `make switch`.**

Проверь `hyprctl monitors -j`, `hyprctl layers -j` и лог
`~/.cache/noctalia/noctalia.log`. Если композитор жив, а слоёв нет —
перезапусти Noctalia. Если нет и композитора — переключись на tty и
`systemctl restart greetd`.

**Noctalia не убивается обычным способом.**

`pgrep -f noctalia`, затем `kill -9 <pid>`; `pgrep -x` даёт ложный минус.

## Nix и кэш

**`cache.nixos.org` отдаёт 502/503 или таймауты.**

Это Fastly; повтори сборку. Запасные substituters уже прописаны в
`common/nix/cache.nix`: `mirror.yandex.ru/nixos` и `nixos.snix.store`.
Не удаляй store и поколения «на всякий случай».

**Сборка падает на скачивании NAR через VPN.**

В `host/nix/daemon.nix` стоит `max-substitution-jobs = 2`; при плохой сети
временно поставь `1`. Проверь `ip route` и внешний IP, не статус юнита.

## Секреты

**Активация падает на sops / `user-password`.**

У машины нет ключа, который может расшифровать `secrets/secrets.yaml`.
Варианты: добавить host-age и `sops updatekeys` (`docs/new-machine.md`) или
поставить `#MagicBookInstall` без sops и потом пересобраться. Сборка
(`nix build`) ключ не требует.

**`sops updatekeys` не видит ключ.**

Нужен admin-ключ или host-ключ, доступный пользователю; root-only
`/run/secrets-for-users.d/age-keys.txt` для скриптов от Michael не подходит.
Детали — `docs/secrets.md`.

## ISO

**`make build-iso` падает на `mksquashfs`/DNS.**

Повтори: часть derivations уже в store, останется squashfs. Если ошибка
сети — это не конфиг. `result-iso-custom` при неудаче остаётся старым;
проверь `readlink -f result-iso-custom`.

**ISO не грузится на другом ноуте.**

Secure Boot выключить; нужен x86_64/UEFI. Ventoy обновлять до 1.1.18 не
обязательно (в nixpkgs он помечен insecure). Если ISO не видит диск —
смотри `docs/iso.md`, там `disko` и `nixos-install`.
