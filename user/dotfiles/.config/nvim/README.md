# nvim config

Native Neovim 0.13 + `vim.pack`; `~/.config/nvim` is a symlink to this
directory.

- `init.lua` — bootstrap: providers, loader, pack, core modules, theme.
- `lua/pack.lua` — specs and `load` / `runtime` / `use` / `register`.
- `lua/core/` — editor primitives; `lua/plugins/` — third-party lifecycle.
- `lua/flat/` — flatwhite/flatblack; theme sections live in `lua/flat/theme/`.
- `nvim-pack-lock.json` — lockfile; commit it, do not hand-edit.

Architecture, trigger map, theme notes and validation: `docs/nvim.md`.
