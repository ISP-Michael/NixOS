{
  imports = [
    ./boot.nix
    ./console.nix
    ./hardware-configuration.nix
    ./networking.nix
    ./scripts
    ./services
    ./settings
    ./soft
    ./system
    ./time.nix
    ./users
  ];
  documentation = {
    man = {
      generateCaches = false;
    };
  };
  nixpkgs = {
    config = {
      permittedInsecurePackages = [
        "ciscoPacketTracer8-8.2.2"
      ];
    };
  };
}


