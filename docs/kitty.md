# kitty

`~/.config/kitty/kitty.conf` is a hub with `include conf.d/*.conf`; kitty
0.49.2. The split keeps palette, font, cursor, behavior and local keys
separate.

## Current options

- FiraCode Nerd Font NDD, size 12, ligatures enabled, `ss01..ss10`/`cv*`;
  italic and bold-italic get the same feature set.
- Cursor block with zero blink, cursor trail; `cursor none` leaves the cell
  inversion to the terminal.
- 5 px padding, no audio bell, 10k lines of local scrollback (tmux keeps
  50k), copy on select, URL detection/hyperlinks, no tab bar.
- `shell_integration disabled`: tmux and zsh own the prompt/session
  environment. In 0.49 the old value `no` is invalid and is silently
  ignored, so the previous config actually loaded with `invalid`.

## Theme

Noctalia's built-in `kitty` template renders `themes/noctalia.conf`; the hub
includes it last so it overrides `conf.d/colors.conf`. On `SUPER+W` /
`theme.sh light|dark`, Noctalia regenerates the file and sends `USR1` to
running kitty instances. The hand-written `colors.conf` is the dark fallback
when Noctalia is absent.

## New in kitty 0.49 worth knowing

- `shell_integration enabled` (or a list of `no-*` flags): prompt marks,
  previous-command pager, cwd tracking, `clone-in-kitty`, `sudo` integration.
  It is the prerequisite for `notify_on_cmd_finish`.
- `notify_on_cmd_finish invisible 10.0`: desktop notification for long
  commands in an invisible window; needs shell integration. Candidate after
  testing kitty+zsh+tmux together.
- `kitten hints` (bound to `ctrl+shift+e`): keyboard-selectable URLs, paths,
  hashes and words; `kitten hints --type=path` is useful for file paths.
- `kitten choose-fonts`, `kitten ssh`, `kitten transfer`, `kitten clipboard`,
  `kitten notify`, `kitten quick-access-terminal`.
- Sessions (`kitty --session`), `--single-instance`, `--instance-group`,
  remote control (`--listen-on`), `background_blur`, `window_logo_path`,
  `tab_bar_style`/`tab_powerline_style`, `undercurl_style`, `cursor_trail_color`.
- `allow_hyperlinks`, `detect_urls`, `url_style`, `detect_url_regex` are
  configured explicitly; they were already defaults.

## Why shell integration is still off

Enabling it changes shell startup and adds prompt/cwd hooks. The current zsh
config does not source kitty's integration script, and tmux sits between the
shell and kitty. It is worth testing as a separate change, with
`notify_on_cmd_finish invisible 10.0`; do not enable both blind.

## Validation

```bash
cd /etc/nixos
kitty +runpy 'from kitty.config import load_config; bad=[]; c=load_config("user/dotfiles/.config/kitty/kitty.conf", accumulate_bad_lines=bad); print("bad", bad); print(c.font_size, c.shell_integration, c.scrollback_lines, c.enable_audio_bell)'
```

This loads all includes without opening a window. Old vs new effective-option
diff: only `shell_integration`, `scrollback_lines`, `enable_audio_bell` and
the extra italic font features changed; all other values are identical.
