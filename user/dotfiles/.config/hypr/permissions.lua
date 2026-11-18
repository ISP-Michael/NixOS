-- Permission rules for Hyprland 0.57.1 (ecosystem.enforce_permissions).
--
-- With enforce_permissions = 0 everything is allowed and no prompts appear.
-- With 1 every client without a matching rule goes through the ask dialog.
-- The five permission types are screencopy, plugin, keyboard, cursor_pos and
-- input_capture.
--
-- hl.permission() matches a regex against the canonical /proc/<pid>/exe path
-- with RE2::FullMatch over the whole path. In Nix, many packages are wrappers:
-- the real binary is .<name>-wrapped, and /etc/profiles symlinks resolve to
-- /nix/store/<hash>-<name>. Rules therefore need the store path with a hash
-- wildcard and an optional dot/wrapper suffix.
--
-- Rules apply on Hyprland restart, not on reload.
hl.config(
  {
    ecosystem = {
      enforce_permissions = true,
    },
  }
)

-- Screenshots and colour picker.
hl.permission('/nix/store/[^/]*/bin/grim', 'screencopy', 'allow')
hl.permission('/nix/store/[^/]*/bin/hyprpicker', 'screencopy', 'allow')

-- Noctalia's lock screen captures the screen for its background.
hl.permission('/nix/store/[^/]*/bin/\\.?noctalia(-wrapped)?', 'screencopy', 'allow')

-- xdg-desktop-portal-hyprland serves OBS, Discord, Telegram and browsers.
hl.permission('/nix/store/[^/]*/libexec/\\.?xdg-desktop-portal-hyprland(-wrapped)?', 'screencopy', 'allow')

-- Plugin manager.
hl.permission('/nix/store/[^/]*/bin/hyprpm', 'plugin', 'allow')

-- Rollback: set enforce_permissions = false and restart Hyprland.
