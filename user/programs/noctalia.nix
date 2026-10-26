{
  pkgs,
  ...
}:
{
  programs = {
    noctalia = {
      systemd.enable = true;
      enable = true;
      package = import ../noctalia-patched.nix { inherit pkgs; };
    };
  };
}
