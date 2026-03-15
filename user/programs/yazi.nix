{
  pkgs,
  ...
}:
{
  programs = {
    yazi = {
      enable = true;
      plugins = {
        inherit (pkgs.yaziPlugins)
          chmod
          full-border
          piper
          rich-preview
          ;
      };
    };
  };
}
