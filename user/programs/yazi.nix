{
  pkgs,
  inputs,
  ...
}:
{
  programs = {
    yazi = {
      enable = true;
      plugins = {
        chmod        = pkgs.chmod;
        full-border  = pkgs.full-border;
        glow         = inputs.glow;
        office       = inputs.office;
        piper        = pkgs.piper;
        rich-preview = pkgs.rich-preview;
      };
    };
  };
}
