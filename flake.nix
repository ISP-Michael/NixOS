{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

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
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs = {
          follows = "nixos-stable";
        };
      };
    };

    stylix = {
      url = "github:danth/stylix";
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

    autopair = {
      url = "github:jorgebucaran/autopair.fish/main";
      flake = false;
    };

    done = {
      url = "github:franciscolourenco/done/master";
      flake = false;
    };

    fzf = {
      url = "github:PatrickF1/fzf.fish/main";
      flake = false;
    };
  };

  outputs =
    {
      home-manager,
      nixos-unstable,
      nixos-stable,
      nixpkgs,
      nur,
      self,
      sops-nix,
      stylix,
      winapps,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      unstable-pkgs = nixos-unstable.legacyPackages.${system};
      master-pkgs = nixpkgs.legacyPackages.${system};
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
                  neovim = unstable-pkgs.neovim;
                  hyprland = unstable-pkgs.hyprland;
                  telegram-desktop = unstable-pkgs.telegram-desktop;
                  throne = unstable-pkgs.throne;
                  unciv = unstable-pkgs.unciv;
                  xdg-desktop-portal-hyprland = unstable-pkgs.xdg-desktop-portal-hyprland;
                  neovide = unstable-pkgs.neovide;
                  quickshell = unstable-pkgs.quickshell;
                })
              ];
            };
          }
          ./host/configuration.nix
          nur.modules.nixos.default
          sops-nix.nixosModules.sops
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
                  nh = unstable-pkgs.nh;
                  firefox = unstable-pkgs.firefox;
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
