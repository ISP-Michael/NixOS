{
  pkgs,
  ...
}:
{
  programs = {
    yazi = {
      enable = true;
      plugins = {
        chmod        = pkgs.yaziPlugins.chmod;
        full-border  = pkgs.yaziPlugins.full-border;
        piper        = pkgs.yaziPlugins.piper;
        rich-preview = pkgs.yaziPlugins.rich-preview;
      };
    };
  };
}
