# Environment for every zsh. Keep it cheap: no compinit, no plugins.
typeset -U path

# User-local binaries. Guard the directories so a fresh host or ISO does not
# get dead PATH entries; $HOME keeps this portable.
[[ -d $HOME/.local/bin ]] && path=("$HOME/.local/bin" $path)
[[ -d $HOME/.opencode/bin ]] && path=("$HOME/.opencode/bin" $path)

# Hyprland: if the instance signature was not inherited (script, systemd unit,
# agent), find the socket. One zsh glob, no external processes.
if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  typeset -a _hl_locks
  _hl_locks=( ${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr/*/hyprland.lock(Nom) )
  if (( ${#_hl_locks} )); then
    export HYPRLAND_INSTANCE_SIGNATURE=${${_hl_locks[1]:h}:t}
  fi
  unset _hl_locks
fi
