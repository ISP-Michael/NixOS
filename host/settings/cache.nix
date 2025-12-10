{
  nix = {
    settings = {
      substituters = [        
        "https://nix-community.cachix.org"
        "https://chaotic-nyx.cachix.org"
        "https://winapps.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "winapps.cachix.org-1:HI82jWrXZsQRar/PChgIx1unmuEsiQMQq+zt05CD36g="
      ];
      trusted-users = [
        "Michael"
      ];
    };
  };
}
