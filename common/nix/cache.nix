{
  nix = {
    settings = {
      # Fastly/cache.nixos.org периодически отдаёт 502/503, а с VPN рвутся
      # долгие NAR-загрузки. Не долбим кэш 16 параллельными запросами:
      # меньше соединений, больше попыток, быстрее отрицательный TTL.
      http2 = false;
      download-attempts = 8;
      http-connections = 4;
      narinfo-cache-negative-ttl = 300;
      stalled-download-timeout = 60;
      extra-substituters = [
        "https://noctalia.cachix.org"
      ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
      substituters = [
        "https://cache.nixos.org"
        # Зеркало cache.nixos.org с тем же ключом (проверено: narinfo и Sig
        # совпадают). Русский IP, но по скорости здесь медленнее официального;
        # поэтому запасной, а не основной.
        "https://mirror.yandex.ru/nixos"
        # snix отдаёт NAR без сжатия; priority=100 делает его запасным,
        # а не основным (у самого snix в nix-cache-info priority=39).
        "https://nixos.snix.store?priority=100"
        "https://chaotic-nyx.cachix.org"
        "https://hyprland.cachix.org"
        "https://freesmlauncher.cachix.org"
      ];
      trusted-substituters = [
        "https://nixos.snix.store"
        "https://hyprland.cachix.org"
        "https://freesmlauncher.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "freesmlauncher.cachix.org-1:Jcp5Q9wiLL+EDv8Mh7c6L9xGk+lXr7/otpKxMOuBuDs="
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };
}
