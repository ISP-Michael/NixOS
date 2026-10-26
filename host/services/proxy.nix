{
  pkgs,
  ...
}:
{
  services = {
    v2raya = {
      enable = false;
      cliPackage = pkgs.v2ray;
    };
  };
}
