# Hyprland config

Entry points:

- host: `hyprland.lua` → `manifest.lua` + `monitors.lua` + `autostart.lua`;
- live ISO: `iso/config/hypr/hyprland.lua` → `manifest.lua` + ISO
  `autostart.lua`.

`require('profile')` resolves to the host `profile.lua` or the ISO one because
the ISO entry puts `iso/config/hypr` first in `package.path`.

| Path | Responsibility |
|---|---|
| `manifest.lua` | shared module list: one place to add a new module |
| `profile.lua` | system differences: apps, commands, geometry |
| `settings/` | declarative config by Hyprland root (`hl.config`, animations, gestures) |
| `binds/` | keybindings by domain |
| `rules/` | window, dialog and layer rules |
| `lib/` | pure helpers and shared defaults |
| `autostart.lua` | per-system startup |

Deep notes and the reasons behind unusual settings: `docs/hyprland.md`.
