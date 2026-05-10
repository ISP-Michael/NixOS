{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowUnsupportedSystem = true;
      android_sdk.accept_license = true;
      permittedInsecurePackages = [
        "ventoy-1.1.10"
      ];
    };
  };
}
