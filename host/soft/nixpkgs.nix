{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowUnsupportedSystem = true;
      android_sdk.accept_license = true;
      permittedInseurePackages = [
        "ventoy-1.1.10"
      ];
    };
  };
}
