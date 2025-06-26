{
  imports = [
    ./soft
    ./scripts
    ./boot.nix
    ./users.nix
    ./system.nix
    ./options.nix
    ./console.nix
    ./services.nix
    ./networking.nix
    ./hardware-configuration.nix
  ];

  stylix = {
    image = ../dependencies/images/CatpuccinLake.png;
    polarity = "dark";
    autoEnable = false;
  };
}
