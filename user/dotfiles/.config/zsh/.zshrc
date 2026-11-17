# Каталог состояния (история, zcompdump) — на новой системе его ещё нет
mkdir -p "$HOME/.local/state/zsh"

autoload -Uz compinit
fpath=($HOME/.config/zsh/completions $fpath)
if [[ -r $HOME/.local/state/zsh/zcompdump ]]; then
  compinit -C
fi

_lazy_antidote() {
  (( _antidote_lazy_done )) && return
  antidote load "$HOME/.config/zsh/plugins_lazy.txt" >/dev/null 2>&1
  _antidote_lazy_done=1
  [[ -f $HOME/.local/share/fzf-marks ]] || : > $HOME/.local/share/fzf-marks
}

abbr() { _lazy_antidote; abbr "$@" }
bd() { _lazy_antidote; bd "$@" }
mark() { _lazy_antidote; mark "$@" }
jump() { _lazy_antidote; jump "$@" }
pmark() { _lazy_antidote; pmark "$@" }
dmark() { _lazy_antidote; dmark "$@" }

zle -N _lazy_mark
_lazy_mark() { _lazy_antidote; [[ -f $HOME/.local/share/fzf-marks ]] || : > $HOME/.local/share/fzf-marks; mark }
zle -N _lazy_fzm
_lazy_fzm() { _lazy_antidote; [[ -f $HOME/.local/share/fzf-marks ]] || : > $HOME/.local/share/fzf-marks; fzm }
bindkey -M viins '^b' _lazy_mark
bindkey -M viins '^g' _lazy_fzm

_lazy_forgit() {
  _lazy_antidote
  local cmd=$1; shift
  "${aliases[$cmd]}" "$@"
}
for _c in ga grh grs glo grl gd gso gi gat gcf gcff gcb gsw gco gct gbd grc gclean gss gsp gcp grb gfu gsq grw gbl gwt gwa gwd; do
  alias "$_c=_lazy_forgit $_c"
done
unset _c

zvm_after_select_vi_mode() {
  [[ $1 == insert ]] && {
    (( $+functions[autopair-init] )) && autopair-init
    bindkey -M viins '^b' _lazy_mark
    bindkey -M viins '^g' _lazy_fzm
  }
}

ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd

[[ -r $HOME/.local/state/zsh/zcompdump && $HOME/.local/state/zsh/zcompdump -nt $HOME/.config/zsh/.zshrc ]] || compinit -d $HOME/.local/state/zsh/zcompdump

source $HOME/.config/zsh/antidote/antidote.zsh
antidote load $HOME/.config/zsh/plugins.txt

bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

(( $+functions[autopair-init] )) && autopair-init

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

# zsh-vi-mode подвешивает zvm_init в precmd_functions (zsh-vi-mode.zsh:4079),
# а не при source. Значит он отрабатывает на ПЕРВОМ промпте — уже после всего
# .zshrc — и там делает bindkey -v (main становится ссылкой на viins) и затирает
# привязки, которые .zshrc объявил выше. Замер после свежей загрузки:
#   ^?      backward-delete-char  вместо autopair-delete (Backspace не убирает пару)
#   ^U      zvm_viins_undo        вместо kill-whole-line
#   ^W      backward-kill-word    вместо autopair-delete-word
#   M-b M-f undefined-key         вообще не привязаны
# Ручной source ~/.config/zsh/.zshrc помогает потому, что zvm_init при повторном
# source уже не выполняется (ZVM_INIT_DONE=true) и перебить больше некому.
# Хук ниже встаёт в precmd_functions ПОСЛЕ zvm_init и возвращает своё один раз.
function _my_restore_bindings() {
  local map
  for map in main emacs viins; do
    bindkey -M $map '^?'        autopair-delete
    bindkey -M $map '^h'        autopair-delete
    bindkey -M $map '^U'        kill-whole-line
    bindkey -M $map '^W'        autopair-delete-word
    bindkey -M $map $'\e[1;5D' backward-word
    bindkey -M $map $'\e[1;5C' forward-word
    bindkey -M $map $'\eb'      backward-word
    bindkey -M $map $'\ef'      forward-word
  done
  add-zsh-hook -d precmd _my_restore_bindings
}
add-zsh-hook -Uz precmd _my_restore_bindings

() {
  local d=$HOME/.cache/zsh
  mkdir -p $d
  if [[ ! -f $d/init.stamp || $d/init.stamp -ot $HOME/.config/zsh/.zshrc ]]; then
    fzf --zsh >$d/fzf.zsh 2>/dev/null
    zoxide init zsh >$d/zoxide.zsh 2>/dev/null
    zsh -fc 'for f in "$1" "$2"; do zcompile "$f" 2>/dev/null; done' _ $d/fzf.zsh $d/zoxide.zsh
    touch $d/init.stamp
  fi
  source $d/fzf.zsh 2>/dev/null
  source $d/zoxide.zsh 2>/dev/null
}

HISTFILE=$HOME/.local/state/zsh/history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_FIND_NO_DUPS

alias e="nvim"

PROMPT='%n@%m:%~ > '

zstyle ':completion:*' list-separator '│'
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/compcache"

# fzf-tab берёт Tab на себя (fzf.zsh переопределяет binding)
bindkey -M emacs '^I' fzf-tab-complete
bindkey -M viins '^I' fzf-tab-complete
bindkey -M vicmd '^I' fzf-tab-complete

# Разделитель групп в fzf-tab вместо ──
zstyle ':fzf-tab:*' fzf-flags '--no-separator'

autoload -U select-word-style
select-word-style bash
WORDCHARS=''

# Восстанавливаем интеграцию kitty, которую перетерла строка PROMPT
if [[ -n "$KITTY_INSTALLATION_DIR" && -e "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh" ]]; then
  source "$KITTY_INSTALLATION_DIR/shell-integration/zsh/kitty.zsh"
fi

if [ -n "$TMUX" ]; then
  alias clear='clear && tmux clear-history'
  alias reset='reset && tmux clear-history'

  # Ctrl+L: штатный clear-screen чистит только видимый экран, прокрутка в tmux
  # остаётся. Две тонкости, обе проверены замерами:
  #   1) clear-screen шлёт ED(2), а terminfo-clear ещё и ED(3) — прокрутку
  #      стирает именно ED(3), поэтому одного tmux clear-history мало.
  #   2) zle буферизует вывод виджета и отправляет его ПОСЛЕ тела виджета,
  #      так что tmux clear-history отработал бы раньше очистки и tmux занёс бы
  #      старый экран в историю обратно. zle -R принудительно сбрасывает буфер.
  _my_clear_screen() {
    zle clear-screen
    zle -R
    tmux clear-history >/dev/null 2>&1
  }
  zle -N _my_clear_screen
  # во все три карты: bindkey -e / -v из переключателя Alt+V делает linkkey
  bindkey -M emacs '^L' _my_clear_screen
  bindkey -M viins '^L' _my_clear_screen
  bindkey -M main  '^L' _my_clear_screen
fi

# opencode
export PATH=/home/Michael/.opencode/bin:$PATH
eval "$(starship init zsh)"
# ===== работа со строкой промпта =====

# Ctrl+Left / Ctrl+Right — шаг по словам (в zsh не работает из коробки)
bindkey -M emacs $'\e[1;5D' backward-word
bindkey -M emacs $'\e[1;5C' forward-word
bindkey -M viins $'\e[1;5D' backward-word
bindkey -M viins $'\e[1;5C' forward-word

# то же через Alt
bindkey -M emacs $'\eb' backward-word
bindkey -M emacs $'\ef' forward-word

# Ctrl+U — удалить строку, Ctrl+W — удалить слово.
# В карте viins задаём явно, чтобы не зависеть от дефолтов vi.
bindkey -M emacs '^U' kill-whole-line
bindkey -M emacs '^W' autopair-delete-word
bindkey -M viins '^U' kill-whole-line
bindkey -M viins '^W' autopair-delete-word

# Переключатель emacs <-> vi по Alt+V.
# Флаг свой, а не [[ -o vi ]]: плагин zsh-vi-mode этот option не трогает.
typeset -g _MY_VI=0
_my_vi_toggle() {
  if (( _MY_VI )); then
    bindkey -e
    _MY_VI=0
    print -z -- 'режим редактирования: emacs'
  else
    bindkey -v
    _MY_VI=1
    print -z -- 'режим редактирования: vi  (Esc или Ctrl+[ — выйти из режима вставки)'
  fi
  (( $+functions[autopair-init] )) && autopair-init
  zle reset-prompt
}
zle -N _my_vi_toggle
bindkey -M emacs $'\ev' _my_vi_toggle
bindkey -M viins $'\ev' _my_vi_toggle

# Редактор текста для sudoedit
export EDITOR='nvim'

# ---------- Python/uv: автоактивация .venv ----------
# uv run меняет окружение только у дочернего процесса, поэтому Starship
# не видит venv в родительском shell. Активируем .venv при входе в проект
# и снимаем, когда уходим. Отключить: VENV_NO_AUTOACTIVATE=1.
_uv_project_root() {
  local dir=$PWD
  while [[ $dir != / ]]; do
    if [[ -f $dir/.venv/bin/activate && -x $dir/.venv/bin/python ]]; then
      print -r -- "$dir"
      return 0
    fi
    dir=${dir:h}
  done
  return 1
}

_uv_auto_activate() {
  local root

  if [[ -n ${VENV_NO_AUTOACTIVATE:-} || -n ${UV_NO_AUTOACTIVATE:-} ]]; then
    if [[ -n ${_UV_AUTO_VENV:-} && ${VIRTUAL_ENV:-} == "${_UV_AUTO_VENV}/.venv" ]]; then
      (( $+functions[deactivate] )) && deactivate
    fi
    _UV_AUTO_VENV=""
    return 0
  fi

  if [[ -n ${_UV_AUTO_VENV:-} ]]; then
    root=$(_uv_project_root) || root=""
    [[ $root == "${_UV_AUTO_VENV}" ]] && return 0
    if [[ ${VIRTUAL_ENV:-} == "${_UV_AUTO_VENV}/.venv" ]]; then
      (( $+functions[deactivate] )) && deactivate
    fi
    _UV_AUTO_VENV=""
  fi

  [[ -n ${VIRTUAL_ENV:-} ]] && return 0
  root=$(_uv_project_root) || return 0
  if source "$root/.venv/bin/activate" 2>/dev/null; then
    _UV_AUTO_VENV=$root
  fi
}

typeset -g _UV_AUTO_VENV="${_UV_AUTO_VENV:-}"
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _uv_auto_activate
_uv_auto_activate
