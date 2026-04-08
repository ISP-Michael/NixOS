{
  programs = {
    fish = {
      shellInit = ''
        set -gx College ~/Projects/College
        set -gx Design ~/Projects/College/Design
        set -gx Downloads ~/Downloads
        set -gx Project ~/Projects/College/Practice_3
        set -gx activate .venv/bin/activate.fish
        set -gx config /home/Michael/.config
        set -gx kitty ~/.config/kitty/kitty.conf
        set -gx nixos /etc/nixos
        set -gx nvim ~/.config/nvim/init.vim
        set -gx fish_greeting ""
        zoxide init fish | source
      '';
    };
  };
}
