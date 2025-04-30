{ pkgs, ... }:
{
  programs = {
    yazi = {
      enable = true;
      plugins = with pkgs; {
        chmod = yaziPlugins.chmod;
        full-border = yaziPlugins.full-border;
        rich-preview = yaziPlugins.rich-preview;
      };
    };
  };
}
