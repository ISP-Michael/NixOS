{
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        py = "python";
        fucking = "sudo";
        dn = "dotnet";
        ndw = "nmcli device wifi";
        update = "ga /etc/nixos && nix flake update --flake /etc/nixos";
        rebuild = "ga /etc/nixos && nixos-rebuild switch --flake /etc/nixos --sudo";
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
