{
  unstable-pkgs,
  ...
}:
{
  imports = [
    "${unstable-pkgs.path}/nixos/modules/programs/throne.nix"
  ];
  disabledModules = [
    "programs/nekoray.nix"
  ];
  config = {
    programs = {
      throne = {
        enable = true;
        tunMode = {
          enable = true;
          setuid = true;
        };
      };
    };
  };
}
