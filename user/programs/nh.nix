{
  programs = {
    nh = {
      enable = true;
      flake = /etc/nixos;
      clean = {
        enable = true;
        dates = "daily";
        extraArgs = "--keep-one --keep 3";
      };
    };
  };
}
