{
  pkgs,
  ...
}:
{
  # Сборки не должны забирать машину целиком: на 6 ГБ mksquashfs и компиляция
  # вытесняют композитор в своп, и Hyprland начинает пропускать кадры.
  # CPUWeight/IOWeight важны только при конкуренции, MemoryHigh мягко
  # останавливает рост памяти (без MemoryMax, чтобы не убивать компиляторы).
  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 20;
    IOWeight = 50;
    MemoryHigh = "3G";
  };

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
      max-substitution-jobs = 16;
      keep-outputs = true;
      keep-derivations = true;
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (10 * 1024 * 1024 * 1024)}";
    };
  };
}
