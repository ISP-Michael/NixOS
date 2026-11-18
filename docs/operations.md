# Проверки, деплой, пуш

## Локально

```bash
make check       # eval всех конфигураций, без требования чистого дерева
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

`make check` разрешает грязное дерево (`ALLOW_DIRTY=1`), `make ci` — нет.
`make build`/`switch` делают только быстрый предполётный контроль (чистое
дерево и `git diff --check`), потому что полный eval всех конфигов и ISO
дублирует работу `nixos-rebuild` и на 6 ГБ уходит в своп. Полная проверка —
`make ci`, она же запускается в `make push`.

Сборки идут через `nix-daemon` с `CPUWeight=20`, `IOWeight=50` и
`MemoryHigh=3G` (`host/nix/daemon.nix`): при конкуренции приоритет у
десктопа, память сборки не вытесняет композитор в своп.

## Что проверяет CI

- `git diff --check`;
- `nix eval` всех 7 конфигураций;
- `nix eval` всех 5 ISO-пакетов;
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
