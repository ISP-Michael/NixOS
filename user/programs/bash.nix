{
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        py = "python";
        fucking = "sudo";
        ndw = "nmcli device wifi";
        rebuild = "sudo nixos-rebuild switch";
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
