# Секреты

Полная инструкция: [`../docs/secrets.md`](../docs/secrets.md).

Коротко:

- `secrets/secrets.yaml` — зашифрованный системный секрет `user-password`;
- `secrets/apps.yaml` — необязательный зашифрованный снимок OpenCode/OpenClaw;
- `secrets/opencode-restic/` — restic-репозиторий сессий, gitignored;
- приватные ключи, `auth.json`, `service.json`, `openclaw.json`, `*.db` —
  в git не попадают.

Сборка (`nix build`, `nixos-rebuild build`) ключ не требует; активация и
установка — требуют.
