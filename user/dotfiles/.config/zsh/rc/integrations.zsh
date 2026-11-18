# Cached fzf/zoxide integration.
() {
  local dir=$ZSH_CACHE_DIR
  local stamp=$dir/init.stamp

  if [[ ! -f $stamp || $stamp -ot $ZSH_CONFIG_DIR/rc/integrations.zsh ]]; then
    fzf --zsh >"$dir/fzf.zsh" 2>/dev/null
    zoxide init zsh >"$dir/zoxide.zsh" 2>/dev/null
    zsh -fc 'for f in "$1" "$2"; do zcompile "$f" 2>/dev/null; done' \
      _ "$dir/fzf.zsh" "$dir/zoxide.zsh"
    touch "$stamp"
  fi

  [[ -r $dir/fzf.zsh ]] && source "$dir/fzf.zsh"
  [[ -r $dir/zoxide.zsh ]] && source "$dir/zoxide.zsh"
}

if [[ -n ${TMUX:-} ]]; then
  alias clear='clear && tmux clear-history'
  alias reset='reset && tmux clear-history'

  # Ctrl+L: clear the visible screen and tmux scrollback. ED(3) from the
  # terminal's clear is what actually removes the scrollback; zle -R flushes
  # the widget's output before tmux clear-history runs.
  _my_clear_screen() {
    zle clear-screen
    zle -R
    tmux clear-history >/dev/null 2>&1
  }

  zle -N _my_clear_screen
  bindkey -M emacs '^L' _my_clear_screen
  bindkey -M viins '^L' _my_clear_screen
  bindkey -M main '^L' _my_clear_screen
fi
