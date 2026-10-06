{
  inputs,
  system,
  ...
}:
{
  programs = {
    noctalia = {
      systemd.enable = true;
      enable = true;
      package = inputs.noctalia.packages.${system}.default;
    };
  };
}
