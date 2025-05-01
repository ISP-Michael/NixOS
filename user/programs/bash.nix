{
  programs.bash = {
    enable = true;
    shellAliases = {
      py = "python";
      dn = "dotnet";
      fucking = "sudo";
      ndw = "nmcli device wifi";
      update = "nix flake update --flake /etc/nixos";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
    sessionVariables = {
      EDITOR = "nvim";
    };
    initExtra = ''
      set -o vi
    '';
  };
}
