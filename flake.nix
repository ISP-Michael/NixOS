{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

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
                  acpi = unstable-pkgs.acpi;
                  brightnessctl = unstable-pkgs.brightnessctl;
                  csharp_ls = unstable-pkgs.csharp_ls;
                  neovim = unstable-pkgs.neovim;
                  nekoray = unstable-pkgs.nekoray;
                  hyprland = unstable-pkgs.hyprland;
                  telegram-desktop = unstable-pkgs.telegram-desktop;
                  unciv = unstable-pkgs.unciv;
                  quickshell = unstable-pkgs.quickshell;
                  xdg-desktop-portal-hyprland = unstable-pkgs.xdg-desktop-portal-hyprland;
                  noto-fonts-color-emoji = unstable-pkgs.noto-fonts-color-emoji;
                  neovide = unstable-pkgs.neovide;
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
                  waybar = unstable-pkgs.waybar;
                  kanata = unstable-pkgs.kanata;
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
