{
  programs = {
    fish = {
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
    };
  };
}
