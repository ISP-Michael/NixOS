# History. Keep the shared/global-rc options explicit so the config does not
# silently depend on /etc/zshrc.
HISTFILE=$ZSH_STATE_DIR/history
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_FIND_NO_DUPS
setopt HIST_FCNTL_LOCK
