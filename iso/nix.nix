{
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
        "nixos"
      ];
      warn-dirty = false;
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
