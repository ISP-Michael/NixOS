# Antidote is sourced by completion.zsh; keep a guard for direct sourcing.
if (( ! $+functions[antidote] )); then
  source "$ZSH_CONFIG_DIR/vendor/antidote/antidote.zsh"
fi

# Main bundles load after compinit. The order in plugins/main.txt owns
# fzf-tab/autosuggestions/syntax-highlighting constraints.
antidote load \
  "$ZSH_CONFIG_DIR/plugins/main.txt" \
  "$ANTIDOTE_HOME/static/main.zsh"

# fzf-tab replaces Tab after compinit.
bindkey -M emacs '^I' fzf-tab-complete
bindkey -M viins '^I' fzf-tab-complete
bindkey -M vicmd '^I' fzf-tab-complete
zstyle ':fzf-tab:*' fzf-flags '--no-separator'

# Lazy bundles. The flag survives re-sourcing; wrappers remove themselves
# before loading so a failed load cannot recurse.
typeset -g _antidote_lazy_done=${_antidote_lazy_done:-0}

_lazy_antidote() {
  (( _antidote_lazy_done )) && return 0
  antidote load \
    "$ZSH_CONFIG_DIR/plugins/lazy.txt" \
    "$ANTIDOTE_HOME/static/lazy.zsh" || return
  _antidote_lazy_done=1
}

if (( ! $+functions[abbr] )); then
  abbr() {
    unfunction abbr 2>/dev/null
    _lazy_antidote || return
    abbr "$@"
  }
fi

if (( ! $+functions[bd] )); then
  bd() {
    unfunction bd 2>/dev/null
    _lazy_antidote || return
    bd "$@"
  }
fi

if (( ! $+functions[mark] )); then
  mark() {
    unfunction mark 2>/dev/null
    _lazy_antidote || return
    mark "$@"
  }
fi

if (( ! $+functions[jump] )); then
  jump() {
    unfunction jump 2>/dev/null
    _lazy_antidote || return
    jump "$@"
  }
fi

if (( ! $+functions[pmark] )); then
  pmark() {
    unfunction pmark 2>/dev/null
    _lazy_antidote || return
    pmark "$@"
  }
fi

if (( ! $+functions[dmark] )); then
  dmark() {
    unfunction dmark 2>/dev/null
    _lazy_antidote || return
    dmark "$@"
  }
fi

zle -N _lazy_mark
_lazy_mark() {
  _lazy_antidote || return
  mark
}

zle -N _lazy_fzm
_lazy_fzm() {
  _lazy_antidote || return
  fzm
}

bindkey -M viins '^b' _lazy_mark
bindkey -M viins '^g' _lazy_fzm

_lazy_forgit() {
  _lazy_antidote || return
  local cmd=$1
  shift
  "${aliases[$cmd]}" "$@"
}

if (( ! _antidote_lazy_done )); then
  for _c in ga grh grs glo grl gd gso gi gat gcf gcff gcb gsw gco gct gbd grc gclean gss gsp gcp grb gfu gsq grw gbl gwt gwa gwd; do
    alias "$_c=_lazy_forgit $_c"
  done
  unset _c
fi
