# Проверки, деплой, пуш

## Локально

```bash
make check       # быстрый eval: MagicBook + iso-custom, грязное дерево можно
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

`make check` — быстрый режим: `MagicBook` и `iso-custom`, грязное дерево
разрешено (`ALLOW_DIRTY=1`). `make ci` — полный: все 7 конфигураций и
5 ISO-пакетов, только на чистом дереве. Полный режим запускается в
`make push` и в GitHub Actions.

`nix eval` в обоих режимах идёт в отдельной cgroup:
`MemoryHigh=2G`, `MemoryMax=3G`, `MemorySwapMax=512M` для `check` и
`3G/4G/1G` для `ci`. Если eval упрётся в лимит, он умрёт сам, а не утянет
за собой композитор. В CI без user-systemd — обычный eval без лимита.

`make build`/`switch` делают только быстрый предполётный контроль (чистое
дерево и `git diff --check`), потому что полный eval всех конфигов и ISO
дублирует работу `nixos-rebuild` и на 6 ГБ уходит в своп.

Сборки идут через `nix-daemon` с `CPUWeight=20`, `IOWeight=50` и
`MemoryHigh=3G` (`host/nix/daemon.nix`): при конкуренции приоритет у
десктопа, память сборки не вытесняет композитор в своп.

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
