# OpenClaw: реальные директории + bootstrap (без Nix-симлинков)

OpenClaw — живое приложение: пишет `~/.openclaw/openclaw.json`, обновляет
сессии, secret store, создаёт файлы. Поэтому конфиг и секреты **не**
линкуются из Nix store и не собираются через `nh os switch`. Nix управляет
системой, а состояние приложения живёт в родных директориях.

## Что лежит здесь

```
openclaw.json.tmpl              # обезличенный шаблон; install.sh создаёт из него конфиг
systemd/user/                   # шаблоны user-units
bin/                            # скрипты обслуживания
```

Живые файлы:

```
~/.openclaw/openclaw.json
~/.config/systemd/user/openclaw-*.service / *.timer
~/.local/state/opencode/openclaw-*.py
~/.local/state/opencode/openclaw-gateway-restart.sh
```

## Установка/обновление

```bash
user/dotfiles/.config/apps/install.sh          # не перезаписывает существующее
FORCE=1 user/dotfiles/.config/apps/install.sh  # перезаписать, сделав .bak
```

Скрипт ставит симлинки на плагины/скрипты, рендерит `openclaw.json` из
`openclaw.json.tmpl` (если файла ещё нет; токены = `REPLACE_ME`) и user-units
с `@HOME@`/`@PYTHON@`. Существующие файлы не перезаписывает. `auth.json` и
secret store не трогает.

Сессии и память бэкапятся отдельно: `opencode-backup.timer` → `backup-data.sh`
(restic, репозиторий в `secrets/opencode-restic`, пароль в
`~/.local/state/opencode/restic.pass`). Восстановление — `restore-data.sh`.

Включить один раз:

```bash
systemctl --user daemon-reload
systemctl --user enable --now openclaw-maintenance.timer
systemctl --user enable --now openclaw-gateway-restart.timer
systemctl --user enable --now openclaw-dashboard-web.service
```

## Секреты и перенос

- Живые секреты — в `~/.openclaw/openclaw.json` (gateway token, API key) и
  в secret store OpenClaw (Telegram bot token), права 0600.
- Опциональный зашифрованный снимок: `secrets/apps.yaml` (sops).
  Создать/обновить: `user/dotfiles/.config/apps/backup.sh`.
  Восстановить: `user/dotfiles/.config/apps/restore.sh`.
- Смена ключа: правишь живой конфиг/`openclaw secrets store set`, приложение
  сразу использует новый ключ. Пересборка не нужна. Снимок обновляешь
  отдельно, если он тебе нужен.
- Подробно про sops — `secrets/README.md`.

## Перенос на другую машину

1. Скопировать флейк/`user/dotfiles/.config` и `secrets/apps.yaml`, если есть.
2. Установить OpenClaw/OpenCode.
3. `install.sh` — units/скрипты/конфиги.
4. `restore.sh` — конфиг/авторизация из снимка (или положить вручную).
5. Добавить ключ новой машины в `.sops.yaml`, `sops updatekeys`.
6. Заполнить Telegram token, если он `REPLACE_ME`.
7. Сессии/историю перенести отдельно, если нужны.

## Модели и 429

Конфиг: primary `deepseek-v4.1-flash`, fallback `glm-5.3-flash` — это твой
выбор, GLM только страховка. 429 — перегрузка провайдера, а не «сломалась
модель». `modelOverride` конкретной сессии — runtime-данные; если сессия
вручную закреплена на модели, fallback может не сработать. Это лечится
снятием override (UI или БД), а не правкой конфига/пересборкой.
