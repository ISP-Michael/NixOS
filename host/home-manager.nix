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
    backupFileExtension = "backup";
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
        # Вся пользовательская конфигурация собрана в user/default.nix.
        # Так точка входа одна и для хоста, и для чтения агентом.
        imports = [
          "${self}/user"
        ];
      };
    };
  };
}
