# Paths and directories used by the interactive shell. Everything generated
# lives under XDG state/cache, never in the repo.
typeset -g ZSH_CONFIG_DIR=${ZSH_CONFIG_DIR:-${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}}
typeset -g ZSH_STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/zsh
typeset -g ZSH_CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/zsh
typeset -g ANTIDOTE_HOME=${ANTIDOTE_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/antidote}
typeset -g ABBR_USER_ABBREVIATIONS_FILE=$ZSH_STATE_DIR/abbreviations
typeset -g FZF_MARKS_FILE=$ZSH_STATE_DIR/fzf-marks

mkdir -p -m 700 \
  "$ZSH_STATE_DIR" \
  "$ZSH_CACHE_DIR" \
  "$ZSH_CACHE_DIR/completions"
