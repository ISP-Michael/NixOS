{
  programs.fish = {
    enable = true;
    shellAliases = {
      g            = "git";
      n            = "nvim";
      fucking      = "sudo";
      rgi          = "rg -i";
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
      dll          = "dotnet bin/Debug/net10.0/*.dll";
      hyprshot     = "hyprshot -o ~/Images/screenshots";
      ff           = "fastfetch --logo ~/Images/patterns_2.png";
      update       = "sudo nix flake update --flake /etc/nixos";
      rebuild_boot = "ga /etc/nixos && sudo nixos-rebuild boot --flake /etc/nixos";
      rebuild      = "ga /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos";
      delete_shots = "find ~/Images/screenshots -maxdepth 1 -type f -name '*.png' -delete";
    };
    shellInit = ''
      zoxide init fish | source
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
