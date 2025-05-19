{
  programs.fish = {
    enable = true;
    shellAliases = {
      g            = "git";
      fucking      = "sudo";
      r            = "reset";
      py           = "python";
      dn           = "dotnet";
      ga           = "git add";
      gl           = "git log";
      gpsh         = "git push";
      gpll         = "git pull";
      gs           = "git status";
      gb           = "git branch";
      gco          = "git checkout";
      bnc          = "brightnessctl";
      gci          = "git commit -m";
      ndw          = "nmcli device wifi";
      bat_h-l      = "bat --highlight-line 0:";
      dll          = "dotnet bin/Debug/net9.0/*.dll";
      hyprshot     = "hyprshot -o ~/Images/screenshots";
      update       = "sudo nix flake update --flake /etc/nixos";
      fastfetch    = "fastfetch --logo ~/Images/nixos-logo.png";
      rebuild      = "sudo nixos-rebuild switch --flake /etc/nixos";
      delete_shots = "find /home/Michael -maxdepth 1 -type f -name '*.png' -delete";
      rsync_nixos  = "cd ~/nixos && rsync -av --exclude-from='.rsync-ignore' /etc/nixos ~ && cd -";
    };
    shellInit = ''
      set -gx nixos /etc/nixos
      set -gx Downloads ~/Downloads
      set -gx College ~/Projects/College
      set -gx config /home/Michael/.config
      set -gx nvim ~/.config/nvim/init.vim
      set -gx Design ~/Projects/College/Design
      set -gx activate .venv/bin/activate.fish
      set -gx kitty ~/.config/kitty/kitty.conf
      set -gx Project ~/Projects/College/Practice_3
    '';
    interactiveShellInit = ''
      fish_vi_key_bindings
    '';
    functions = {
      git         = builtins.readFile ./func_git.fish;
      tree        = builtins.readFile ./func_tree.fish;
      dotnet      = builtins.readFile ./func_dotnet.fish;
      fish_prompt = builtins.readFile ./fish_prompt.fish;
    };
  };
}
