{
  inputs,
  self,
  nur,
  system,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = {
      inherit inputs self nur system;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      Michael = {
        imports = [
          ../user/home.nix
          ../user/mimeapps.nix
          ../user/packages.nix
          ../user/programs
          ../user/scripts
          ../user/services
          ../user/stylix
          inputs.stylix.homeModules.stylix
        ];
        nixpkgs = {
          config = {
            allowUnfree = true;
          };
        };
      };
    };
  };
}
