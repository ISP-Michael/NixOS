{
  programs.fish = {
    enable = true;
    shellAliases = {
      bat_h-l      = "bat --highlight-line 0:";
      bnc          = "brightnessctl";
      delete-shots = "find ~/Images/screenshots -maxdepth 1 -type f -name '*.png' -delete";
      dll          = "dotnet bin/Debug/net10.0/*.dll";
      dn           = "dotnet";
      ff           = "fastfetch --logo ~/Images/patterns_2.png";
      fucking      = "sudo";
      g            = "git";
      ga           = "git add";
      gb           = "git branch";
      gci          = "git commit -m";
      gco          = "git checkout";
      gl           = "git log";
      gpll         = "git pull";
      gpsh         = "git push";
      gs           = "git status";
      home-rebuild = "ga . && home-manager switch --flake /etc/nixos";
      hyprshot     = "hyprshot -o ~/Images/screenshots";
      n            = "nvim";
      ndw          = "nmcli device wifi";
      py           = "python";
      r            = "reset";
      rebuild      = "ga /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos";
      rebuild_boot = "ga /etc/nixos && sudo nixos-rebuild boot --flake /etc/nixos";
      rgi          = "rg -i";
      update       = "sudo nix flake update --flake /etc/nixos";
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
