{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    hyprland.url = "github:hyprwm/Hyprland/2eb5180c6f258bb73c4b9b71a1361dede0e1453e";
    freesmlauncher.url = "github:FreesmTeam/FreesmLauncher/be4e50d06ad0fea34bf3dc0ff83e1fda4cad33eb";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
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
    freesmlauncher,
    nix-flatpak,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    mkHost = extraModules: nixpkgs.lib.nixosSystem {
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
            };
          };
          services = {
            btrfs = {
              autoScrub = {
                enable = true;
              };
            };
          };
        }
      ] ++ extraModules;
    };
    mkIso = profile: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          self
          nur
          system
          ;
      };
      modules = [
        ./iso/configuration.nix
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        home-manager.nixosModules.home-manager
        {
          iso.profile = profile;
          nixpkgs = {
            config = {
              allowUnfree = true;
            };
          };
        }
      ] ++ nixpkgs.lib.optionals (profile != "lite") [
        ./iso/vpn.nix
      ];
    };
    configs = {
      MagicBook = mkHost [];
      MagicBookInstall = mkHost [
        ./iso/install-overrides.nix
      ];
      iso = mkIso "work";
      iso-lite = mkIso "lite";
      iso-media = mkIso "media";
      iso-full = mkIso "full";
      iso-custom = mkIso "custom";
    };
  in
  {
    nixosConfigurations = configs;
    packages.${system} = {
      iso = configs.iso.config.system.build.isoImage;
      iso-lite = configs.iso-lite.config.system.build.isoImage;
      iso-media = configs.iso-media.config.system.build.isoImage;
      iso-full = configs.iso-full.config.system.build.isoImage;
      iso-custom = configs.iso-custom.config.system.build.isoImage;
    };
  };
}
