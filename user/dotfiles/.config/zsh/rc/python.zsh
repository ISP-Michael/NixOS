# Python/uv: activate .venv when entering a project and deactivate on leave.
# This executes code from the tree; opt out with VENV_NO_AUTOACTIVATE=1 or
# UV_NO_AUTOACTIVATE=1.
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
