{
  inputs,
  ...
}:
{
  home-manager = {
    users = {
      drfoobar = {
        imports = [
          inputs.noctalia.homeModules.default
        ];
        programs = {
          noctalia-shell = {
            enable = true;
          };
        };
      };
    };
  };
}
