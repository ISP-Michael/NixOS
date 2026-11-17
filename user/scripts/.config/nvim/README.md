# nvim config

Native Neovim 0.13 config. Plugin management is `vim.pack`; there is no
lazy.nvim and no plugin-manager shim.

## Layout

- `init.lua` — options, pack, core modules, theme, lualine.
- `lua/pack.lua` — plugin specs, `PackLoadAll`, and three load primitives:
  - `P.load(name)` — `:packadd`, sources `plugin/` and `ftdetect/`;
  - `P.runtime(name)` — `:packadd!`, only adds runtime files (queries,
    parsers, `lsp/`, syntax) after startup;
  - `P.use(name)` — runs the registered setup loader.
- `lua/plugins/*.lua` — one file per plugin/group. Requiring them only
  installs keymaps/autocmds; plugin code is loaded on first use.
- `lua/core/*.lua` — editor behavior, native LSP, native tree-sitter,
  completion docs, indent.
- `lua/flat/*`, `lua/lualine/themes/*`, `colors/*` — current flatblack theme.

## Plugin loading

`pack.setup()` calls `vim.pack.add(specs, { load = function() end })`. The
callable load is deliberate: with `load = false` vim.pack calls `:packadd!`,
which puts every plugin on `runtimepath`, and Neovim's normal startup then
sources all `plugin/` files anyway. The no-op keeps plugin directories off
`runtimepath` until `P.load` / `P.runtime` asks for one.

Everything expensive is behind a trigger: first file (LSP), matching
filetype (tree-sitter, text objects, autotag, SQL), first key (fzf, neo-tree,
DAP, Spectre, Trouble, LazyGit, EasyAlign, surround), first notification
(snacks), first save (conform), first scroll (neoscroll). `gitsigns` is
skipped entirely for buffers outside a `.git` repository.

`:PackLoadAll` force-loads every configured plugin; it exists for tests and
benchmarks, not for normal startup.

## Caching / startup

- `vim.loader.enable()` caches compiled Lua under `~/.cache/nvim/luac`.
- `loaded_*_provider` turns off Neovim's Python/Ruby/Perl/Node probes; the
  Python probe alone cost ~100 ms on the first `.py` buffer.
- `flat.cursor` no longer calls tree-sitter/LSP from the colorscheme; the
  cursor group is updated on the first cursor move instead.
- LSP's runtime files are added on the first file; the tree-sitter plugin is
  loaded on the first matching filetype.  Text objects are set up with it,
  once per session.

## Old LazyVim config

The previous config is preserved twice:

- `~/.config/nvim-lazy` — runnable copy;
- `~/.local/share/opencode/backups/nvim-lazyvim-2026-11-11.tar.gz` — archive.

Run it with:

```sh
NVIM_APPNAME=nvim-lazy nvim
```

It shares `~/.local/share/nvim-lazy` with the installed lazy.nvim plugins, so
it needs no separate plugin install.

## Plugins and benchmark

```sh
nvim          # normal
:packupdate   # update plugins; review the buffer and :write
./bench.sh    # old vs new: empty, Python file, all plugins, all + Python
N=15 ./bench.sh
```

`nvim-pack-lock.json` is the lockfile; commit it. Do not edit it by hand.

## Neovide / project root

- `~/.config/nvim` is shared by terminal Neovim and Neovide.
- Neovide no longer sets `autochdir`; otherwise `fzf-lua` starts from the
  directory of the current file.
- `:ProjectRoot [dir]` and `<leader>pp` choose a project directory. In
  Neovide the picker is `kdialog`; the choice is saved in
  `stdpath('state')/project-root` and reused on the next launch.
- On launch with a file, the root is the nearest `.git`, `flake.nix`,
  `Cargo.toml`, `package.json`, `pyproject.toml`, `go.mod`, `Makefile`,
  `CMakeLists.txt` or `compile_commands.json`; otherwise the file's directory.
- `<leader>ff` and `<leader>fg` pass that root as `cwd` to `fzf-lua`, so a
  file opened deep in the tree does not move the search root.
- Terminal Neovim keeps the shell cwd; `fzf` still anchors at the nearest
  project marker above it. Use `:ProjectRoot` to override the detection.

Neovide app settings live in `~/.config/neovide/config.toml`; runtime visuals
are in `lua/core/neovide.lua`. The custom nightly derivation installs the
desktop entry and hicolor icons, so rofi sees it.

## Measured on this machine

Median of 13 runs, milliseconds:

| case | lazy.nvim | vim.pack | faster |
|---|---:|---:|---:|
| empty, no plugins | 54 | 33 | 1.66x |
| Python file | 241 | 126 | 1.92x |
| all plugins forced (`PackLoadAll`) | 119 | 111 | 1.07x |
| all plugins + Python file | 315 | 223 | 1.41x |

The forced all-plugin case is bounded by third-party plugin code; `PackLoadAll`
is a stress test, not the normal startup path.
