{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs";

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    stylix = {
      url = "github:danth/stylix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    autopair.url = "github:jorgebucaran/autopair.fish/main";
    done.url     = "github:franciscolourenco/done/master";
    fzf.url      = "github:PatrickF1/fzf.fish/main";

    autopair.flake = false;
    done.flake     = false;
    fzf.flake      = false;
  };

  outputs =
    {
      home-manager,
      nixpkgs-unstable,
      nixpkgs,
      nur,
      self,
      stylix,
      winapps,
      ...
    }@inputs:
    let
      system        = "x86_64-linux";
      unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
      winapps-pkgs  = winapps.packages.${system};
    in
    {
      nixosConfigurations.MagicBook = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            self
            unstable-pkgs
            nur
            winapps-pkgs
            ;
        };
        modules = [
          {
            nixpkgs = {
              overlays = [
                (final: prev: {
                  acpi                        = unstable-pkgs.acpi;
                  neovim                      = unstable-pkgs.neovim;
                  nekoray                     = unstable-pkgs.nekoray;
                  hyprland                    = unstable-pkgs.hyprland;
                  telegram-desktop            = unstable-pkgs.telegram-desktop;
                  xdg-desktop-portal-hyprland = unstable-pkgs.xdg-desktop-portal-hyprland;
                  csharp_ls                   = unstable-pkgs.csharp_ls;
                  brightnessctl               = unstable-pkgs.brightnessctl;
                  unciv                       = unstable-pkgs.unciv;
                  quickshell                  = unstable-pkgs.quickshell;
                })
              ];
            };
          }
          ./host/configuration.nix
          nur.modules.nixos.default
        ];
      };
      homeConfigurations.Michael = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit
          inputs
            self
            unstable-pkgs
            nur
            winapps-pkgs
            ;
        };
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                nh     = unstable-pkgs.nh;
                waybar = unstable-pkgs.waybar;
                kanata = unstable-pkgs.kanata;
              })
            ];
          }
          ./user/standalone.nix
          stylix.homeModules.stylix
        ];
      };
    };
}
