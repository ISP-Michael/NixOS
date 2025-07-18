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
        gcl          = "git clone";
        gd           = "git diff";
        gl           = "git log";
        grb          = "git rebase";
        grl          = "git reflog";
        grv          = "git revert";
        grs          = "git reset";
        grm          = "git remote";
        gpll         = "git pull";
        gpsh         = "git push";
        gs           = "git status";
        gsb          = "git submodule";
        gsh          = "git stash";
        gsw          = "git switch";
        gm           = "git merge";
        gf           = "git fetch";
        home-rebuild = "ga . && home-manager switch --flake /etc/nixos";
        hyprshot     = "hyprshot -o ~/Images/screenshots";
        n            = "nvim";
        ndw          = "nmcli device wifi";
        py           = "python";
        r            = "reset";
        rebuild      = "ga /etc/nixos && nixos-rebuild switch --use-remote-sudo --flake /etc/nixos";
        rebuild-boot = "ga /etc/nixos && nixos-rebuild boot --use-remote-sudo --flake /etc/nixos";
        rgi          = "rg -i";
        update       = "nix flake update --flake /etc/nixos";
      };
    };
  };
}
