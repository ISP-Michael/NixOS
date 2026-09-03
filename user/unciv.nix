{
  config,
  ...
}:
{
  xdg = {
    desktopEntries = {
      unciv = {
        name = "Unciv";
        exec = "unciv --data-dir=${config.home.homeDirectory}/.local/share/unciv";
        icon = "unciv";
        categories = [
          "Game"
        ];
        comment = "An open-source Android/Desktop remake of Civ V";
      };
    };
  };
}
