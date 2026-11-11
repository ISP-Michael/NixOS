# Перенос OpenCode/OpenClaw на новую машину

Этот файл — инструкция для человека и для ИИ-агента. Цель: перенести
конфиги, плагины, units и сессии, не закоммитив секреты и не перезаписав
живые файлы.

## Что где лежит

```
/etc/nixos/user/scripts/.config/          # git, источник истины
├── opencode/
│   ├── opencode.jsonc.tmpl               # шаблон: @HOME@, @CHROMIUM@
│   ├── cli.json                          # статика → симлинк
│   ├── package.json                      # статика → симлинк
│   ├── plugins/                          # код плагинов → симлинк
│   └── systemd/user/opencode-backup.*    # шаблоны units
├── openclaw/
│   ├── openclaw.json.tmpl                # шаблон, токены REPLACE_ME
│   ├── bin/*.py, *.sh                    # рабочие скрипты → симлинки
│   └── systemd/user/*                    # шаблоны units
└── apps/
    ├── install.sh                        # bootstrap
    ├── backup.sh / restore.sh            # sops-снимок (опционально)
    └── README.md                         # описание схемы
```

Живые данные (не в git):

- `~/.openclaw/openclaw.json` — токены и настройки, права 0600;
- `~/.local/share/opencode/auth.json` — авторизация OpenCode;
- `~/.local/state/opencode/service.json` — runtime-пароль сервиса;
- `~/.local/share/opencode/opencode.db` — сессии (812 МБ);
- `~/.openclaw/agents/` — сессии OpenClaw (275 МБ);
- `~/.config/opencode/node_modules/` — зависимости, ставятся npm.

## Главные правила

1. Секреты **не** коммитить и **не** класть в git. В шаблонах только
   `REPLACE_ME`.
2. `~/.openclaw` целиком **не** симлинковать: там ~900 МБ данных и секреты.
3. `openclaw.json` не перезаписывать: `install.sh` создаёт его только если
   файла нет, даже `--force` его не трогает.
4. Перед изменениями — `install.sh --dry-run`. `--force` делает `.bak`.
5. Сессии — только restic, не git.

## 0. Что скопировать

Минимум:

```text
/etc/nixos/user/scripts/.config/          # конфиги и скрипты
/etc/nixos/secrets/opencode-restic/       # restic-репозиторий (gitignored)
~/.local/state/opencode/restic.pass       # пароль restic (0600)
```

Опционально: `/etc/nixos/secrets/apps.yaml` (sops-снимок конфигов/авторизации).

Если клонируешь git, помни: `secrets/opencode-restic/` в git нет — копируй
каталог отдельно. Если копируешь `/etc/nixos` целиком, он приедет.

## 1. Зависимости

Нужны: OpenCode, OpenClaw, Node.js, Python 3, Chromium, `restic`, `sqlite3`.
На NixOS `restic` и `sqlite` уже добавлены в `host/soft/packages.nix`;
после копирования конфига — `sudo nh os switch /etc/nixos`.

Проверка:

```bash
command -v opencode openclaw node python3 chromium restic sqlite3
```

## 2. Bootstrap

```bash
cd /etc/nixos
user/scripts/.config/apps/install.sh --dry-run   # посмотреть план
user/scripts/.config/apps/install.sh             # применить
```

Что делает `install.sh`:

- ставит симлинки на `cli.json`, `package.json`, `plugins`, скрипты;
- рендерит `~/.config/opencode/opencode.jsonc` из шаблона
  (`@HOME@`, `@CHROMIUM@`);
- создаёт `~/.openclaw/openclaw.json` из шаблона, **только если его нет**;
- рендерит units (`@HOME@`, `@PYTHON@`, `@NODE@`, `@PROFILE@`);
- делает `npm install`, если нет `node_modules`;
- вызывает `systemctl --user daemon-reload`.

На уже настроенной машине всё существующее будет `skip`. `--force` заменяет
с `.bak`; `openclaw.json` защищён отдельно.

## 3. Секреты

В `~/.openclaw/openclaw.json` заменить `REPLACE_ME`:

- `gateway.auth.token` — токен gateway (придумать/сгенерировать);
- `env.vars.OPENCODE_API_KEY` — ключ OpenCode Go;
- `models.providers.opencode-go.apiKey` — он же для провайдера;
- `channels.telegram.allowFrom` — твой Telegram user ID.

`channels.telegram.botToken.id` уже равен `TELEGRAM_BOT_TOKEN_V3` — это
**имя секрета**, не токен. Сам токен положить в secret store:

```bash
printf '%s' '<telegram-token>' > /tmp/tg-token
openclaw secrets store set TELEGRAM_BOT_TOKEN_V3 --value-file /tmp/tg-token
rm -f /tmp/tg-token
```

Или используй `~/.local/state/opencode/openclaw-seed-telegram.sh <file>`.

OpenCode-авторизация:

```bash
opencode auth login
```

`auth.json` и `service.json` с другой машины не копировать: это runtime/
секреты, они пересоздаются.

## 4. Запуск

```bash
systemctl --user daemon-reload
systemctl --user restart openclaw-gateway
systemctl --user enable --now openclaw-maintenance.timer
systemctl --user enable --now openclaw-gateway-restart.timer
systemctl --user enable --now opencode-backup.timer
```

Проверка:

```bash
opencode --version
openclaw infer web search --query "test"
systemctl --user is-active openclaw-gateway opencode-backup.timer
```

## 5. Сессии

Restic-репозиторий и пароль — те, что скопированы в шаге 0. По умолчанию:

```text
RESTIC_REPOSITORY=/etc/nixos/secrets/opencode-restic
RESTIC_PASSWORD_FILE=~/.local/state/opencode/restic.pass
```

Остановить OpenCode/OpenClaw, затем:

```bash
FORCE=1 ~/.local/state/opencode/restore-data.sh
```

Без `FORCE=1` существующие файлы не перезаписываются. `DRY_RUN=1` показывает
план. После восстановления — запустить приложения.

Ручной бэкап:

```bash
~/.local/state/opencode/backup-data.sh
```

Таймер `opencode-backup.timer` делает это ежедневно. Хранится 7 daily /
4 weekly / 6 monthly. `restic forget --prune` встроен.

## 6. Как обновлять конфиги

| Что | Как |
|---|---|
| `cli.json`, `package.json`, `plugins/`, скрипты | правишь в репо — симлинк сразу видит |
| `opencode.jsonc` | правишь `opencode.jsonc.tmpl`, затем `install.sh --force` |
| `openclaw.json` | правишь живой файл; шаблон не трогаешь |
| units | правишь шаблон, затем `install.sh --force` |
| новая зависимость OpenCode | добавь в `package.json`, запусти `npm install --prefix ~/.config/opencode` |

Пересборка Nix не нужна: конфиги и units ставятся скриптом.

## 7. Если что-то сломалось

- Рядом лежат `.bak-YYYYMMDD-HHMMSS` — верни нужный файл.
- Restic: `restic snapshots`, `restic restore latest --tag opencode --target /tmp/...`.
- Залипший lock: `restic unlock` (только если нет активного бэкапа).
- Gateway не стартует: `journalctl --user -u openclaw-gateway -n 50`.
- OpenCode не видит плагин: проверь `readlink ~/.config/opencode/plugins` и
  `opencode plugin list`.

## Чек-лист для ИИ-агента

1. Проверить наличие `/etc/nixos/user/scripts/.config/apps/install.sh`.
2. Проверить `opencode`, `openclaw`, `node`, `python3`, `chromium`, `restic`,
   `sqlite3`.
3. Запустить `install.sh --dry-run`; показать пользователю план.
4. Запустить `install.sh`; не использовать `--force` без необходимости.
5. Не трогать `~/.openclaw/openclaw.json`, если он существует.
6. Попросить пользователя заполнить `REPLACE_ME` и Telegram-токен.
7. Включить таймеры, проверить `openclaw infer web search`.
8. Восстановить сессии только по явной команде; сначала `DRY_RUN=1`.
9. Не коммитить `secrets/opencode-restic/`, `restic.pass`, `auth.json`,
   `service.json`, `*.db`, `node_modules`.
