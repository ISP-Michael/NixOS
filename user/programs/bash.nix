{
  programs.bash = {
    enable = true;
    shellAliases = {
      fucking = "sudo";
      py      = "python";
      dn      = "dotnet";
      ndw     = "nmcli device wifi";
      update  = "nix flake update --flake /etc/nixos";
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
