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
        chmod        = pkgs.yaziPlugins.chmod;
        full-border  = pkgs.yaziPlugins.full-border;
        glow         = inputs.glow;
        office       = inputs.office;
        piper        = pkgs.yaziPlugins.piper;
        rich-preview = pkgs.yaziPlugins.rich-preview;
      };
    };
  };
}
