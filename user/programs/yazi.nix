{ pkgs, ... }:
{
  programs = {
    yazi = {
      enable = true;
      plugins = with pkgs; {
        full-border = yaziPlugins.full-border;
        chmod = yaziPlugins.chmod;
        rich-preview = yaziPlugins.rich-preview;
      };
    };
  };
}
