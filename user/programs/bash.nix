{
  lib,
  ...
}:
{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = lib.recursiveUpdate (import ./shell-aliases.nix) {
        gs = "git status";
      };
      historyControl = [ "ignoreboth" "erasedups" ];
      historySize = 50000;
      historyFileSize = 50000;
      initExtra = ''
        set -o vi

        # промпт как в zsh: user@host:/path/ >
        PS1='\u@\h:\w/ > '

        shopt -s cdspell checkwinsize

        # readline: как в zsh (сравнение, завершение)
        bind 'set completion-ignore-case on'
        bind 'set show-all-if-ambiguous on'
        bind 'set skip-completed-text on'
        bind 'set colored-stats on'

        # fzf: Ctrl-R история, Ctrl-T файлы, Alt-C cd, **<TAB> — как fzf-tab
        command -v fzf >/dev/null && eval "$(fzf --bash)"

        # zoxide: z / zi
        command -v zoxide >/dev/null && eval "$(zoxide init bash)"

        # bd: прыжок к родительскому каталогу, как zsh-bd
        bd() {
          local target=$1 dir=$PWD
          if [[ -z $target ]]; then
            builtin cd ..
            return 0
          fi
          while [[ $dir != / ]]; do
            dir=''${dir%/*}
            [[''${dir##*/} == "$target" ]] && {
              builtin cd "$dir"
              return 0
            }
          done
          echo "bd: '$target' not found" >&2
          return 1
        }
      '';
    };
  };
}
