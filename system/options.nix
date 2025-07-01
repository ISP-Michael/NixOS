{
  nix = {
    settings = {
      cores               = 1;
      warn-dirty          = false;
      auto-optimise-store = true;

      experimental-features = [
        "flakes"
        "nix-command"
        "pipe-operators"
      ];

      substituters = [        
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://cachix.cachix.org"
      ];

      trusted-substituters = [
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "https://cachix.cachix.org"
      ];

      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
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

