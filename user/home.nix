{
  self,
  ...
}:
{
  home = {
    username = "Michael";
    stateVersion = "25.05";
    homeDirectory = "/home/Michael";
    sessionVariables = {
      EDITOR = "nvim";
    };
    file = {
      ".local/share/fonts/literata" = {
        source = "${self}/dependencies/fonts/Literata";
        recursive = true;
      };
    };
  };
}
