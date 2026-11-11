# OpenClaw на host-уровне

Сейчас OpenClaw полностью user-level: конфиг в `~/.openclaw`, units в
`~/.config/systemd/user`, скрипты в `~/.local/state/opencode`.

System-level файлов для него нет, поэтому `host/scripts/etc/openclaw/` пуст.

Если появятся:
- systemd **system** unit (не user),
- конфиг в `/etc/openclaw/`,
- системный прокси/сервис для gateway,

складывать их сюда и подключать через `host/scripts/default.nix`.
