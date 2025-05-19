{
  nix = {
    settings = {
      cores               = 1;
      auto-optimise-store = true;
      warn-dirty          = false;
      experimental-features = [
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
      substituters =
        let
          urls = [
            "cache.nixos.org"
            "winapps.cachix.org"
            "hyprland.cachix.org"
            "nix-community.cachix.org"
          ];
        in
        map (url: "https://${url}") urls;
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 14d";
    };
  };
  time.timeZone = "Europe/Moscow";
}
