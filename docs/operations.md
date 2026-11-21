# Проверки, деплой, пуш

## Локально

```bash
make check       # только хост и проверки dotfiles, грязное дерево можно
make keybinds    # пересобрать docs/keybinds.md из binds/*.lua
make status      # здоровье manual-частей: units, /opt, SearXNG, restic
make build-iso   # iso-custom с ограничениями по памяти
make build-noctalia-slow # Noctalia 5.5.0: один core, idle I/O, лимит памяти
make build       # nixos-rebuild build
make switch      # nixos-rebuild switch (спросит sudo)
make push        # строгий ci + git push origin main
make host-age    # публичный age текущего host-ключа
make sops-check  # проверить расшифровку secrets.yaml (без вывода)
make backup-configs # tar app-конфигов в ~/Backups (0600)
```

`make check` — быстрый: только `MagicBook` и проверки dotfiles, грязное
дерево разрешено (`ALLOW_DIRTY=1`). `make ci` — полный: все 7 конфигураций
и 5 ISO-пакетов, только на чистом дереве. Полный режим запускается в
`make push` и в GitHub Actions.

Каждый конфиг проверяется отдельным `nix eval`, без одного мега-eval через
`builtins.getFlake`. Мега-eval копировал весь каталог в store и на 6 ГБ
уходил в своп; отдельные проверки идут последовательно и с меньшим пиком.

`make build`/`switch` делают только предполётный контроль (чистое дерево и
`git diff --check`), потому что `nixos-rebuild` сам вычисляет конфиг.

Отдельных cgroup-лимитов на eval нет: на практике они только тормозили.
У `nix-daemon` остались штатные `daemonCPUSchedPolicy`/`daemonIOSchedClass`
idle — низкий приоритет при конкуренции, без ручных лимитов памяти.

Пока запущена игра, `make check`/`ci`/`switch`/`build`/`build-iso`
отказываются стартовать (`scripts/guard-gaming.sh`). Осознанный обход —
`ALLOW_GAMING=1`.

## Что проверяет CI

- `git diff --check`;
- `nix eval` конфигураций (`MagicBook`, `iso-custom` в быстром режиме;
  все 7 — в полном);
- `nix eval` ISO-пакетов (`iso-custom` в быстром, все 5 — в полном);
- `hypr-check`, `zsh-check`, `nvim-check`;
- отдельно — `make status` для живого состояния.

## Git

- Один коммит — одна логическая правка.
- Тело коммита: что переименовано/удалено и зачем.
- Перед пушем — `make ci`; пуш идёт во все push-URL `origin`
  (gitverse/github/codeberg).
- Секреты и `~/Backups` не коммитятся.

## Полный CI

- GitHub Actions: `.github/workflows/ci.yml` запускает `./scripts/ci.sh`
  на push/pull request.
- Gitverse/Codeberg: тот же скрипт можно повесить на Forgejo Actions;
  отдельного конфига пока нет.
- `nixos-rebuild build`/ISO в CI не запускаются: это долго и требует
  NixOS-раннера. Их делают локально через `make build`/`make build-iso`.
