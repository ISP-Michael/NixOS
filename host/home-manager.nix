{
  config,
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
      identity = {
        inherit (config.host)
          user
          home
          repoPath
          gitName
          gitEmail
          ;
      };
    };
    users = {
      ${config.host.user} = {
        # Вся пользовательская конфигурация собрана в user/default.nix.
        imports = [
          "${self}/user"
        ];
      };
    };
  };
}
