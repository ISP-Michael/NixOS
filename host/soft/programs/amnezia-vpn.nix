{
  unstable-pkgs,
  ...
}:
{
  programs = {
    amnezia-vpn = {
      enable = true;
      package = unstable-pkgs.amnezia-vpn;
    };
  };
}
