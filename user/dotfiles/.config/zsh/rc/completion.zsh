# Completions. zsh-completions must be on fpath before compinit; the static
# bundle lives in the antidote cache, not in the repository.
fpath=(
  "$ZSH_CONFIG_DIR/completions"
  "$ZSH_CACHE_DIR/completions"
  $fpath
)
typeset -U fpath

if (( ! $+functions[antidote] )); then
  source "$ZSH_CONFIG_DIR/vendor/antidote/antidote.zsh"
fi

if ! antidote load \
  "$ZSH_CONFIG_DIR/plugins/completions.txt" \
  "$ANTIDOTE_HOME/static/completions.zsh"
then
  print -u2 "zsh: failed to load the completion bundle"
fi

autoload -Uz compinit
compinit -i -d "$ZSH_STATE_DIR/zcompdump"

zstyle ':completion:*' list-separator '│'
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/compcache"
