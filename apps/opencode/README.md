# OpenCode

- Host: официальный установщик/`~/.opencode/bin/opencode`, обновление —
  `apps/opencode/update.sh` (он же `~/.local/bin/opencode-update`).
  Юнит `opencode-update.timer` лежит в репозитории:
  `user/dotfiles/.config/opencode/systemd/user/`.
- ISO: `apps/opencode/package.nix` — pinned npm tarball 2.3.0.
- Конфиг: `~/.config/opencode` из `user/dotfiles/.config/opencode`;
  секреты — `~/.local/share/opencode/auth.json`.
- Проверка: `opencode --version`, `opencode auth list`.
- Обновление host-бинарника не требует пересборки Nix.
