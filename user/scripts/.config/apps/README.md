# Приложения: bootstrap + симлинки

> Перенос на новую машину: [TRANSFER.md](TRANSFER.md)
> Ручные `/opt`-приложения (Throne/Amnezia/Happ) и OpenClaw: [MANUAL-APPS.md](MANUAL-APPS.md)

OpenCode и OpenClaw — живые приложения: они пишут конфиги, создают файлы,
меняют токены и сессии. Поэтому здесь не Nix-модули, а bootstrap-скрипты.

## Принцип

- **Статические конфиги/плагины/скрипты** — в этом каталоге, в git.
  `install.sh` по умолчанию делает на них **симлинки**: правка в репозитории
  применяется сразу, без пересборки.
- **Шаблоны с путями** (`opencode.jsonc`, `openclaw.json`, systemd units)
  рендерятся при установке: `@HOME@`, `@PYTHON@`, `@CHROMIUM@`, `@PROFILE@`.
- **Живые файлы и секреты** (`openclaw.json` после ввода токенов, `auth.json`,
  `service.json`, `*.db`, `node_modules`, сессии) не симлинкуются и не
  перезаписываются.
- **Сессии** — отдельный restic-бэкап, не git.

## install.sh

```bash
# показать план, ничего не менять
user/scripts/.config/apps/install.sh --dry-run

# по умолчанию: симлинки + рендер шаблонов; существующее не трогает
user/scripts/.config/apps/install.sh

# копии вместо симлинков
user/scripts/.config/apps/install.sh --copy

# перезаписать существующее, сделав .bak
user/scripts/.config/apps/install.sh --force
```

`openclaw.json` — исключение: он создаётся только если его нет. Даже
`--force` не перезаписывает живой файл с токенами. Нужен шаблон заново —
удали файл вручную (будет создан с `REPLACE_ME`).

На уже настроенной машине скрипт печатает `skip` для всего, что существует.
Секреты не переносятся: после первой установки вставь токены вместо
`REPLACE_ME` в `~/.openclaw/openclaw.json`.

## Перенос на новую машину

1. Скопировать флейк/каталог `user/scripts/.config` на новую машину.
2. Установить OpenCode/OpenClaw.
3. `install.sh` — симлинки, шаблоны, units.
4. Запустить `npm install` в `~/.config/opencode` (install.sh делает это сам,
   если есть npm и нет `node_modules`).
5. Вставить токены в `~/.openclaw/openclaw.json`.
6. Включить таймеры:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now openclaw-maintenance.timer
   systemctl --user enable --now openclaw-gateway-restart.timer
   systemctl --user enable --now opencode-backup.timer
   ```

## Сессии и память

Restic-репозиторий по умолчанию: `/etc/nixos/secrets/opencode-restic/`
(каталог в `.gitignore`, в git не попадает). Пароль:
`~/.local/state/opencode/restic.pass` (0600, генерируется при первом запуске).

```bash
# бэкап вручную (таймер делает это ежедневно)
~/.local/state/opencode/backup-data.sh

# восстановить (сначала остановить OpenCode/OpenClaw)
FORCE=1 ~/.local/state/opencode/restore-data.sh
```

На новую машину переносится каталог `secrets/opencode-restic` и файл
`restic.pass`. Git хранит только конфиги, не сессии: БД и агенты — это
гигабайты и приватные данные.

## Что не переносится

- сессии/история (`opencode.db`, `~/.openclaw/agents/`) — только restic;
- кэши, логи, `browser`, `node_modules`;
- `auth.json`, `service.json`, токены — вставляются вручную.

## Зачем .sh, если есть симлинки

Симлинк только **размещает** файл в нужном месте. Он не умеет:

- создать `~/.openclaw/openclaw.json` из шаблона, если файла ещё нет;
- подставить `@HOME@`/`@PYTHON@`/`@CHROMIUM@`/`@NODE@` под новую машину;
- поставить systemd units, сделать `daemon-reload`, включить таймеры;
- выполнить `npm install` и выставить права.

Это делает `install.sh` — один раз при переносе или после изменения шаблонов.

Остальные `.sh`/`.py` — не bootstrap, а **рабочие задачи**, которые вызывают
systemd-юниты: `backup-data.sh` (restic), `restore-data.sh` (восстановление),
`openclaw-gateway-restart.sh` (ежедневный рестарт), `openclaw-maintenance.py`
(обслуживание). Симлинк на них означает: «запускай актуальную версию из
репозитория», а не копию, которая устареет.
