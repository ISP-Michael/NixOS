{
  config,
  ...
}:
{
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Data/Desktop";
      documents = "${config.home.homeDirectory}/Data/Documents";
      download = "${config.home.homeDirectory}/Data/Downloads";
      music = "${config.home.homeDirectory}/Data/Music";
      pictures = "${config.home.homeDirectory}/Data/Pictures";
      projects = "${config.home.homeDirectory}/Data/Projects";
      publicShare = "${config.home.homeDirectory}/Data/Public";
      templates = "${config.home.homeDirectory}/Data/Templates";
      videos = "${config.home.homeDirectory}/Data/Videos";
    };
  };
}
