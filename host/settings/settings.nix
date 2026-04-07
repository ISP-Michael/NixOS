{
  nix = {
    settings = {
      cores = 1;
      max-jobs = 4;
      warn-dirty = false;
      auto-optimise-store = true;
    };
  };
}
