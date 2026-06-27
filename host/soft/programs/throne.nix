{
  inputs,
  unstable-pkgs,
  unstable-lib,
  git-pkgs,
  pkgs,
  ...
}:
{
  programs = {
    throne = {
      enable = true;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };
  };
}
