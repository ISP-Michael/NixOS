# fastfetch

`~/.config/fastfetch/config.jsonc` is one JSONC file; fastfetch 2.70.0 reads
it directly. No logo: the main use is inside tmux, where kitty/sixel image
logos are not reliably available.

## Current shape

- `display.key.width = 13`, color keys/separator, no bright colors;
- modules are ordered from identity through hardware to runtime state;
- `break` replaces the old empty `custom` spacer;
- added `battery`, `brightness`, `editor`, `localip`, `loadavg`, `processes`,
  `sound`; `packages` now shows Nix system + user counts.

## Useful new features in 2.70

- `--gen-config` writes a config interactively (`fastfetch --gen-config`).
- `--list-presets` / `--config <preset>`: `neofetch`, `screenfetch`, `archey`,
  `ci`, etc.; the local config remains custom.
- `--print-structure` / `--structure`: reorder modules without editing the
  JSON; useful for quick experiments.
- `--dynamic-interval` / `--watch`: keep the fetch refreshing; not used in a
  one-shot shell profile.
- `--format json` and `--stat`: machine-readable output and per-module timing.
- Logo protocols: `kitty`, `kitty-direct`, `sixel`, `chafa`, `iterm`; a real
  image logo is possible outside tmux (`--logo-type kitty --logo ...`).
- New modules worth knowing: `battery`, `brightness`, `poweradapter`,
  `codec`, `processes`, `loadavg`, `localip`, `sound`, `terminalfont`,
  `physicalmemory`, `diskio`, `netio`, `publicip`, `colors`.
- `display.key.width`, `key.padding`, `key.type`, `color-output`,
  `percent-type`, duration formatting.

## Why not more

- `codec` prints two lines (decode/encode) with the same key; left out to
  keep the output one line per fact.
- `poweradapter` and `terminalfont` returned no useful data in this session.
- `publicip` leaks the public address into screenshots; not enabled by
  default.
- `diskio`/`netio` change on every run and make diffs noisy.

## Validation

```bash
cd /etc/nixos
fastfetch -c user/dotfiles/.config/fastfetch/config.jsonc
fastfetch -c user/dotfiles/.config/fastfetch/config.jsonc --format json | jq .
```

`fastfetch` exits non-zero if a module fails; the plain text run above is the
smoke test used for this config.
