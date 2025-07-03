{
  nixpkgs = {
    config = {
      allowUnfree                = true;
      allowBroken                = true;
      allowUnsupportedSystem     = true;
      android_sdk.accept_license = true;
    };
  };
}
