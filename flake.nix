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
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
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
    nix-openclaw,
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    unstable-lib = nixos-unstable.lib;
    unstable-pkgs = import nixos-unstable {
      inherit system;
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
        ];
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
          unstable-lib
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
            overlays = [
              (final: prev: {
                inherit (unstable-pkgs)
                  kitty
                  opencode
                  ;
              })
            ];
            config = {
              allowUnfree = true;
              allowBroken = true;
              allowUnsupportedSystem = true;
              android_sdk.accept_license = true;
              permittedInsecurePackages = [
                "ventoy-1.1.12"
                "docker-28.5.2"
                "pnpm-10.29.2"
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
          self
          unstable-pkgs
          unstable-lib
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
              inputs.nix-openclaw.overlays.default
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
