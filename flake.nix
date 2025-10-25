{
  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs.owner = "NixOS";
    nixpkgs.repo  = "nixpkgs";
    nixpkgs.rev   = "3ff0e34b1383648053bba8ed03f201d3466f90c9";
    nixpkgs.type  = "github";

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-25.05";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    stylix = {
      url = "github:danth/stylix?ref=release-25.05";
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
      ...
    }@inputs:
    let
      system        = "x86_64-linux";
      unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
    in
    {
      nixosConfigurations.MagicBook = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            self
            unstable-pkgs
            nur
            ;
        };
        modules = [
          {
            nixpkgs = {
              overlays = [
                (final: prev: {
                  acpi                        = unstable-pkgs.acpi;
                  neovim                      = unstable-pkgs.neovim;
                  hyprland                    = unstable-pkgs.hyprland;
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
