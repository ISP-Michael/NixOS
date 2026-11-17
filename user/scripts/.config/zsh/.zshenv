
# Added by jcode installer
export PATH="/home/Michael/.local/bin:$PATH"

# poppler-utils (pdftoppm) for yazi office preview
[ -d "$HOME/.local/state/nix/profile/bin" ] && export PATH="$HOME/.local/state/nix/profile/bin:$PATH"

# Hyprland: если инстанс не проброшен (скрипт, systemd-юнит, агент) —
# найти сокет самим. Без этого любой hyprctl отвечает
# "HYPRLAND_INSTANCE_SIGNATURE not set", хотя сессия жива.
# Глоб zsh-овский, без внешних процессов: ls/xargs на каждый шёл добавляли бы
# по несколько миллисекунд к запуску любой подоболочки.
if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  _hl_locks=( ${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr/*/hyprland.lock(Nom) )
  if (( ${#_hl_locks} )); then
    export HYPRLAND_INSTANCE_SIGNATURE=${${_hl_locks[1]:h}:t}
  fi
  unset _hl_locks
fi
