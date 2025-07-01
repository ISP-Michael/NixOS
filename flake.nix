{
  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url                    = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url                    = "github:danth/stylix?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      home-manager,
      nixpkgs-unstable,
      nixpkgs,
      self,
      stylix,
      ...
    }@inputs:
    let
      system        = "x86_64-linux";
      unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      nixosConfigurations.MagicBook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./system/conf.nix {
            nixpkgs.overlays = [
              (final: prev: {
                networkmanager = unstable-pkgs.networkmanager;
              })
            ];
          }
        ];
      };
      homeConfigurations.Michael = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          "${self}/user/conf.nix"
          stylix.homeModules.stylix
        ];
      };
    };
}
