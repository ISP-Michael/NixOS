{
  nix = {
    settings = {
      http2 = false;
      stalled-download-timeout = 30;
      extra-substituters = [
        "https://noctalia.cachix.org"
      ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://cache.garnix.io"
        "https://chaotic-nyx.cachix.org"
        "https://hyprland.cachix.org"
        "https://freesmlauncher.cachix.org"
      ];
      trusted-substituters = [
        "https://cache.garnix.io"
        "https://hyprland.cachix.org"
        "https://freesmlauncher.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ1ndhU/JJbzU8XFnQ="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
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
