# Ordered modules. state first; completion before plugins because
# zsh-completions must be on fpath before compinit; keys last because they
# depend on autopair, fzf-tab and history-substring-search.
typeset -ga ZSH_MODULES=(
  state
  history
  completion
  plugins
  integrations
  keys
  prompt
  python
)

for _module in $ZSH_MODULES; do
  source "$ZSH_CONFIG_DIR/rc/$_module.zsh"
done

unset _module ZSH_MODULES
