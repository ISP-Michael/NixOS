{
  inputs,
  self,
  nur,
  system,
  ...
}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit
        inputs
        self
        nur
        system
        ;
    };
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
          ../user/xdg.nix
          inputs.stylix.homeModules.stylix
        ];
      };
    };
  };
}
