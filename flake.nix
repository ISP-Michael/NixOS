{
  description = "Michael's flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager?rev=f1113939873a62f185c18a51f4e45ae66686822b";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix?rev=75411fe2b90f67bfb4a2ad9cc3b1379758b64dbb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      stylix,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.MagicBook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./system/conf.nix
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.Michael = import ./user/conf.nix;
          }
        ];
      };
    };
}
