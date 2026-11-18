# Interactive hub. The heavy work lives in rc/ modules; a non-interactive
# shell returns before touching the terminal.
[[ -o interactive ]] || return 0

typeset -g ZSH_CONFIG_DIR=${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}
source "$ZSH_CONFIG_DIR/manifest.zsh"
