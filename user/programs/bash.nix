{
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        py      = "python";
        fucking = "sudo";
        dn      = "dotnet";
        ndw     = "nmcli device wifi";
        update  = "nix flake update --flake /etc/nixos";
        rebuild = "nixos-rebuild switch --flake /etc/nixos --sudo";
      };
      sessionVariables = {
        EDITOR = "nvim";
      };
      initExtra = ''
        set -o vi
      '';
    };
  };
}
