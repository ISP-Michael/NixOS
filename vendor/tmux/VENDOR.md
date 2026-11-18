# vendor/tmux

Runtime plugins for the personal tmux config. They are loaded directly by
`user/dotfiles/.config/tmux/conf/session.conf`; TPM is not used.

`user/dotfiles/.config/tmux/vendor` is a symlink to this directory, so the
config keeps stable `~/.config/tmux/vendor/...` paths.

| Directory | Upstream | Version | Notes |
|---|---|---|---|
| `tmux-resurrect` | https://github.com/tmux-plugins/tmux-resurrect | 4.0.0 | local title fix is applied in `scripts/save.sh` and `scripts/restore.sh`; patch kept in `patches/0001-title-fix.patch` |
| `tmux-continuum` | https://github.com/tmux-plugins/tmux-continuum | 3.1.0 | generates `~/.config/systemd/user/tmux.service` when `@continuum-boot` is on |

Removed 18.11.2026 as unused: `catppuccin/tmux`, `tmux-yank`, TPM. The live
config uses the inline Catppuccin fallback and tmux's native clipboard support.
