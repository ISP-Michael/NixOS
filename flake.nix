{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
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
    nix-flatpak,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;

    # Полная система MagicBook: host/ — единственная точка входа.
    mkHost = extraModules: lib.nixosSystem {
      specialArgs = {
        inherit
          inputs
          self
          nur
          system
          ;
      };
      modules = [
        ./host
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

    # Live-ISO: общий слой common/ + профиль iso.profile.
    # VPN-модуль подключается только там, где он есть в профиле.
    profileData = import ./iso/profile-data.nix;

    mkIso = profile: lib.nixosSystem {
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
        ./iso
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
      ] ++ lib.optionals profileData.${profile}.vpn [
        ./iso/vpn.nix
      ];
    };

    configs = {
      MagicBook = mkHost [ ];
      MagicBookInstall = mkHost [
        ./host/install.nix
      ];
      iso = mkIso "work";
      iso-lite = mkIso "lite";
      iso-media = mkIso "media";
      iso-full = mkIso "full";
      iso-custom = mkIso "custom";
    };

    # Все iso-* конфигурации автоматически становятся пакетами:
    # nix build .#iso-custom, .#iso-lite, ...
    isoPackages = lib.mapAttrs' (
      name: cfg: lib.nameValuePair name cfg.config.system.build.isoImage
    ) (lib.filterAttrs (name: _: lib.hasPrefix "iso" name) configs);
  in
  {
    nixosConfigurations = configs;

    packages.${system} = isoPackages;

    formatter.${system} =
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      pkgs.writeShellScriptBin "nixfmt" ''
        exec ${pkgs.python3}/bin/python3 ${./scripts/nix-style.py} "$@"
      '';
  };
}
