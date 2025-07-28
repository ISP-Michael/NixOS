{
  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url         = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs = {
        hyprland = {
          follows = "hyprland";
        };
      };
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs = {
        hyprland = {
          follows = "hyprland";
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
    office.url   = "github:macydnah/office.yazi/main";
    glow.url     = "github:Reledia/glow.yazi/main";

    autopair.flake = false;
    done.flake     = false;
    fzf.flake      = false;
    office.flake   = false;
    glow.flake     = false;
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
        specialArgs = {
          inherit
            inputs
            self
            unstable-pkgs
            ;
        };
        modules = [
          {
            nixpkgs.overlays = [
              (final: prev: {
                acpi                        = unstable-pkgs.acpi;
                neovim                      = unstable-pkgs.neovim;
                networkmanager              = unstable-pkgs.networkmanager;
                hyprland                    = hyprland-pkgs.hyprland;
                xdg-desktop-portal-hyprland = hyprland-pkgs.xdg-desktop-portal-hyprland;
                csharp_ls                   = unstable-pkgs.csharp_ls;
                obs-studio                  = unstable-pkgs.obs-studio;
                brightnessctl               = unstable-pkgs.brightnessctl;
              })
            ];
          }
          ./host/configuration.nix
        ];
      };
      homeConfigurations.Michael = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit
          inputs
            self
            unstable-pkgs
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
