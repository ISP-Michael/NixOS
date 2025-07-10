{
  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
    };
  };
}
