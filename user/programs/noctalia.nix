{
  inputs,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];
  programs = {
    noctalia = {
      systemd.enable = true;
      enable = true;
    };
  };
}
