{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    hyprland.url = "github:hyprwm/Hyprland";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs = {
          follows = "nixos-stable";
        };
      };
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs = {
          follows = "nixos-stable";
        };
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs = {
        nixpkgs = {
          follows = "nixos-stable";
        };
      };
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs = {
        nixpkgs = {
          follows = "nixos-stable";
        };
      };
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs = {
        nixpkgs = {
          follows = "nixos-stable";
        };
      };
    };
  };

  outputs =
    {
      home-manager,
      nixos-unstable,
      nixos-stable,
      nixpkgs,
      nur,
      hyprland,
      self,
      sops-nix,
      stylix,
      winapps,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      unstable-pkgs = import nixos-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      master-pkgs = nixpkgs.legacyPackages.${system};
      hyprland-pkgs = hyprland.packages.${system};
      winapps-pkgs = winapps.packages.${system};
    in
    {
      nixosConfigurations.MagicBook = nixos-stable.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            self
            master-pkgs
            unstable-pkgs
            nur
            hyprland-pkgs
            winapps-pkgs
            ;
        };
        modules = [
          ./host/configuration.nix
          nur.modules.nixos.default
          sops-nix.nixosModules.sops
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
        ];
      };
      homeConfigurations.Michael = home-manager.lib.homeManagerConfiguration {
        pkgs = nixos-stable.legacyPackages.${system};
        extraSpecialArgs = {
          inherit
            inputs
            master-pkgs
            self
            unstable-pkgs
            nur
            hyprland-pkgs
            winapps-pkgs
            ;
        };
        modules = [
          {
            nixpkgs = {
              config = {
                allowUnfree = true;
              };
              overlays = [
                (final: prev: {
                  inherit (unstable-pkgs)
                    nh
                    firefox
                    kitty
                    fish
                    ;
                })
              ];
            };
          }
          ./user/standalone.nix
          stylix.homeModules.stylix
        ];
      };
    };
}
