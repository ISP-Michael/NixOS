{
  pkgs,
  unstable-pkgs,
  ...
}:
{
  nix = {
    package = unstable-pkgs.lixPackageSets.latest.lix;
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      cores = 1;
      max-jobs = 4;
      warn-dirty = false;
      auto-optimise-store = true;
    };
  };
}
