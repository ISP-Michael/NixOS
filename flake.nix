{
  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url         = "github:hyprwm/Hyprland";
    home-manager = {
      url                    = "github:nix-community/home-manager?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url                    = "github:danth/stylix?ref=release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fisher = {
      url   = "github:jorgebucaran/fisher/main";
      flake = false;
    };
    autopair = {
      url   = "github:jorgebucaran/autopair.fish/main";
      flake = false;
    };
    done = {
      url   = "github:franciscolourenco/done/master";
      flake = false;
    };
    fzf = {
      url   = "github:PatrickF1/fzf.fish/main";
      flake = false;
    };
    office = {
      url   = "github:macydnah/office.yazi/main";
      flake = false;
    };
    glow = {
      url   = "github:Reledia/glow.yazi/main";
      flake = false;
    };
  };

  outputs =
    {
      home-manager,
      hyprland,
      nixpkgs-unstable,
      nixpkgs,
      self,
      stylix,
      ...
    }@inputs:
    let
      system        = "x86_64-linux";
      unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
      hyprland-pkgs = hyprland.packages.${system};
    in
    {
      nixosConfigurations.MagicBook = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs self;
        };
        modules = [
          ./system/configuration.nix {
            nixpkgs.overlays = [
              (final: prev: {
                networkmanager              = unstable-pkgs.networkmanager;
                hyprland                    = hyprland-pkgs.hyprland;
                xdg-desktop-portal-hyprland = hyprland-pkgs.xdg-desktop-portal-hyprland;
              })
            ];
          }
        ];
      };
      homeConfigurations.Michael = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs self;
        };
        modules = [
          ./user/standalone.nix
          stylix.homeModules.stylix
        ];
      };
    };
}
