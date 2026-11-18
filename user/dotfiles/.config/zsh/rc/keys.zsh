# Keys and editing behavior.
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

if (( $+functions[autopair-init] )); then
  autopair-init
fi

() {
  local p rchar
  for p in ${(@k)AUTOPAIR_PAIRS}; do
    bindkey -M main "$p" autopair-insert
    bindkey -M viins "$p" autopair-insert
    rchar=$(_ap-get-pair $p)
    if [[ $p != $rchar ]]; then
      bindkey -M main "$rchar" autopair-close
      bindkey -M viins "$rchar" autopair-close
    fi
  done
  bindkey -M main '^?' autopair-delete
  bindkey -M viins '^?' autopair-delete
  bindkey -M main '^h' autopair-delete
  bindkey -M viins '^h' autopair-delete
}

# zsh-vi-mode runs zvm_init from precmd on the first prompt and rebinds keys
# after this file. This hook is registered after zvm_init and restores the
# bindings once.
_my_restore_bindings() {
  local map
  for map in main emacs viins; do
    bindkey -M $map '^?' autopair-delete
    bindkey -M $map '^h' autopair-delete
    bindkey -M $map '^U' kill-whole-line
    bindkey -M $map '^W' autopair-delete-word
    bindkey -M $map $'\e[1;5D' backward-word
    bindkey -M $map $'\e[1;5C' forward-word
    bindkey -M $map $'\eb' backward-word
    bindkey -M $map $'\ef' forward-word
  done
  add-zsh-hook -d precmd _my_restore_bindings
}
autoload -Uz add-zsh-hook
add-zsh-hook -Uz precmd _my_restore_bindings

zvm_after_select_vi_mode() {
  if [[ $1 == insert ]]; then
    (( $+functions[autopair-init] )) && autopair-init
    bindkey -M viins '^b' _lazy_mark
    bindkey -M viins '^g' _lazy_fzm
  fi
}

autoload -U select-word-style
select-word-style bash
WORDCHARS=''

# Alt+V toggles emacs/vi. zle -M shows the mode without touching the buffer.
typeset -g _MY_VI=0
_my_vi_toggle() {
  if (( _MY_VI )); then
    bindkey -e
    _MY_VI=0
    zle -M 'режим редактирования: emacs'
  else
    bindkey -v
    _MY_VI=1
    zle -M 'режим редактирования: vi  (Esc или Ctrl+[ — выйти из режима вставки)'
  fi
  (( $+functions[autopair-init] )) && autopair-init
  zle reset-prompt
}
zle -N _my_vi_toggle
bindkey -M emacs $'\ev' _my_vi_toggle
bindkey -M viins $'\ev' _my_vi_toggle

alias e='nvim'
