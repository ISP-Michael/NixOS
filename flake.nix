{
  description = "Michael's flake";

  inputs = {
    stylix.url = "github:danth/stylix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:Marcecoll/zen-browser-flake";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ayugram-desktop = {
      type = "git";
      submodules = true;
      url = "https://github.com/ndfined-crp/ayugram-desktop";
    };
  };

  outputs =
    {
      self,
      stylix,
      nixpkgs,
      winapps,
      hyprland,
      zen-browser,
      home-manager,
      ayugram-desktop,
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
          winapps-pkgs = winapps.packages.${system};
          hyprland-pkgs = hyprland.packages.${system};
          zen-browser-pkgs = zen-browser.packages.${system};
          ayugram-desktop-pkgs = ayugram-desktop.packages.${system};
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
