{
  identity,
  ...
}:
{
  programs = {
    nh = {
      enable = true;
      flake = identity.repoPath;
      clean = {
        enable = true;
        dates = "daily";
        extraArgs = "--keep-one --keep 3";
      };
    };
  };
}
