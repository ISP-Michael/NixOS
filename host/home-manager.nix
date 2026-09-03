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
          "${self}/user/home.nix"
          "${self}/user/mimeapps.nix"
          "${self}/user/unciv.nix"
          "${self}/user/packages.nix"
          "${self}/user/programs"
          "${self}/user/scripts"
          "${self}/user/services"
          "${self}/user/stylix"
          "${self}/user/xdg.nix"
          inputs.stylix.homeModules.stylix
        ];
      };
    };
  };
}
