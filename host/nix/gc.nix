{
  nix = {
    optimise = {
      automatic = true;
      dates = [
        "12:00"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  systemd = {
    services = {
      # Store maintenance must never compete with a game.
      nix-optimise = {
        serviceConfig = {
          Nice = 19;
          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";
        };
      };
      nix-gc = {
        serviceConfig = {
          Nice = 19;
          IOSchedulingClass = "idle";
          CPUSchedulingPolicy = "idle";
        };
      };
    };
  };
}
