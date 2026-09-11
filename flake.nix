{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    noctalia.url = "github:noctalia-dev/noctalia/1acdc7d229c49d9e337da10d4c536e5c5f38cd20";
    hyprland.url = "github:hyprwm/Hyprland/2eb5180c6f258bb73c4b9b71a1361dede0e1453e";
    freesmlauncher.url = "github:FreesmTeam/FreesmLauncher/be4e50d06ad0fea34bf3dc0ff83e1fda4cad33eb";
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
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
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw/d3760a6f103642f11e24bc01ee9aec80a0153774";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake/afbbbef7c3c00f160f4a9dfdd8c6c6b8b089a33f";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
  };
  outputs = {
    disko,
    home-manager,
    nixpkgs,
    nur,
    self,
    sops-nix,
    stylix,
    freesmlauncher,
    nix-flatpak,
    nix-openclaw,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.MagicBook = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          self
          nur
          system
          freesmlauncher
          ;
      };
      modules = [
        ./host/configuration.nix
        ./happ-nixos/happ-module.nix
        disko.nixosModules.disko
        nix-flatpak.nixosModules.nix-flatpak
        home-manager.nixosModules.home-manager
        nur.modules.nixos.default
        sops-nix.nixosModules.sops
        {
          nixpkgs = {
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
              android_sdk.accept_license = true;
              permittedInsecurePackages = [
                "docker-29.6.2"
              ];
            };
          };
          services = {
            happ = {
              enable = true;
              forceXwayland = true;
              forceSoftwareRendering = true;
            };
            btrfs = {
              autoScrub = {
                enable = true;
              };
            };
          };
        }
      ];
    };
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          self
          ;
      };
      modules = [
        ./iso/configuration.nix
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
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
