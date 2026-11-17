# Скрипты OpenClaw

Источники для bootstrap. `install.sh` копирует их в
`~/.local/state/opencode/`:

- `openclaw-maintenance.py` — catch-up + уведомления + дашборд;
- `openclaw-report.py` — `ocreport` и HTML;
- `openclaw-gateway-restart.sh` — ежедневный restart;
- `openclaw-seed-telegram.sh` — засев токена бота из зашифрованного снимка.

Units используют пути `~/.local/state/opencode/`. Скрипты портируемы:
`OPENCLAW_BIN`/`shutil.which`, `Path.home()`, без привязки к Nix.

Legacy `openclaw-notify.py` и `openclaw-catchup.py` остаются в
`~/.local/state/opencode/`; таймеры используют единый maintenance.
