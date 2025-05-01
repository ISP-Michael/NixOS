{
  programs.fish = {
    enable = true;
    shellAliases = {
      g = "git";
      r = "reset";
      py = "python";
      dn = "dotnet";
      fucking = "sudo";
      bnc = "brightnessctl";
      ndw = "nmcli device wifi";
      bat_h-l = "bat --highlight-line 0:";
      dll = "dotnet bin/Debug/net9.0/*.dll";
      update = "nix flake update --flake /etc/nixos";
      fastfetch = "fastfetch --logo ~/Images/nixos-logo.png";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
      delete_shots = "find /home/Michael -maxdepth 1 -type f -name '*.png' -delete";
    };
    shellInit = ''
      set -gx Downloads ~/Downloads
      set -gx College ~/Projects/College
      set -gx config /home/Michael/.config
      set -gx Design ~/Projects/College/Design
      set -gx activate .venv/bin/activate.fish
      set -gx Project ~/Projects/College/Practice_3
    '';
    interactiveShellInit = ''
      fish_vi_key_bindings
    '';
    functions = {
      fish_prompt = builtins.readFile ./fish_prompt.fish;
    };
  };
}
