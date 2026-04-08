{
  pkgs,
  ...
}:
{
  services = {
    v2raya = {
      enable = true;
      cliPackage = pkgs.v2ray;
    };
  };
}
