{
  lib,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowUnsupportedSystem = true;
      android_sdk.accept_license = true;
      permittedInsecurePackages = [
        "ciscoPacketTracer8-8.2.2"
      ];
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "obsidian"
      ];
    };
  };
}
