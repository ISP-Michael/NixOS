{
  programs = {
    nh = {
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 5 --keep-since 14d";
      };
    };
  };
}
