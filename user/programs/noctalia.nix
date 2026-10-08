{
  pkgs,
  ...
}:
{
  programs = {
    noctalia = {
      systemd.enable = true;
      enable = true;
      package = pkgs.noctalia;
    };
  };
}
