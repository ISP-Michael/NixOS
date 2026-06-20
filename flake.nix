{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    noctalia.url = "github:noctalia-dev/noctalia";
    freesmlauncher.url = "github:FreesmTeam/FreesmLauncher";
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs = {
          follows = "nixos-stable";
        };
      };
    };
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
  };
  outputs = {
    disko,
    home-manager,
    nixpkgs,
    nixos-unstable,
    nixos-stable,
    nur,
    self,
    sops-nix,
    stylix,
    freesmlauncher,
    nix-flatpak,
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
    git-pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in
  {
    nixosConfigurations.MagicBook = nixos-stable.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          self
          unstable-pkgs
          git-pkgs
          nur
          system
          freesmlauncher
          ;
      };
      modules = [
        ./host/configuration.nix
        disko.nixosModules.disko
        nur.modules.nixos.default
        sops-nix.nixosModules.sops
        nix-flatpak.nixosModules.nix-flatpak
        {
          nixpkgs = {
            config = {
              allowUnfree = true;
              allowBroken = true;
              allowUnsupportedSystem = true;
              android_sdk.accept_license = true;
              permittedInsecurePackages = [
                "ventoy-1.1.12"
                "docker-28.5.2"
                "openclaw-2026.5.7"
              ];
            };
            overlays = [
              (final: prev: {
                inherit (unstable-pkgs)
                  kitty
                  ;
              })
            ];
          };
        }
      ];
    };
    homeConfigurations.Michael = home-manager.lib.homeManagerConfiguration {
      pkgs = nixos-stable.legacyPackages.${system};
      extraSpecialArgs = {
        inherit
          inputs
          self
          unstable-pkgs
          git-pkgs
          nur
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
    nixosConfigurations.iso = nixos-stable.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          self
          ;
      };
      modules = [
        "${nixos-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./iso/configuration.nix
        {
          nixpkgs = {
            config = {
              allowUnfree = true;
            };
          };
        }
      ];
    };
  };
}
