{
  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
        # "pipe-operators"  # Not working for Lix
      ];
    };
  };
}
