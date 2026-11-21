{
  pkgs,
  ...
}:
{
  nix = {
    package = pkgs.lixPackageSets.latest.lix;
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      cores = 4;
      max-jobs = 3;
      warn-dirty = false;
      auto-optimise-store = false;
      always-allow-substitutes = true;
      extra-deprecated-features = "or-as-identifier";
      # 4 параллельные загрузки через один VPN-канал дают пачку таймаутов;
      # 2 — компромисс, при плохом дне временно 1.
      max-substitution-jobs = 2;
      keep-outputs = true;
      keep-derivations = true;
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (10 * 1024 * 1024 * 1024)}";
    };
  };
}
