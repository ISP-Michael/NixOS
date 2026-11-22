{
  pkgs,
  config,
  ...
}:
{
  programs = {
    noctalia = {
      systemd.enable = true;
      enable = true;
      package = import ./package.nix { inherit pkgs; };
      settings = {
        shell.font_family = "DejaVu Sans";
        wallpaper.directory = "${config.home.homeDirectory}/Data/Pictures/Wallpapers";
        theme = {
          mode = "dark";
          source = "wallpaper";
          wallpaper_scheme = "m3-content";
          templates = {
            enable_builtin_templates = true;
            enable_community_templates = true;
            builtin_ids = [
              "gtk3"
              "gtk4"
              "qt"
              "btop"
              "kitty"
            ];
            community_ids = [
              "zen-browser"
              "pywalfox"
              "chromium-based"
              "libreoffice"
              "discord"
              "telegram"
              "obsidian"
              "yazi"
              "tmux"
              "starship"
            ];
            user = {
              kcolorscheme = {
                input_path = "$XDG_CONFIG_HOME/noctalia/templates/kcolorscheme.colors";
                output_path = "$XDG_DATA_HOME/color-schemes/noctalia.colors";
                post_action = "kde-color-scheme";
                post_hook = "bash ${config.home.homeDirectory}/.config/noctalia/apply-kde.sh";
              };
              picker_palette = {
                input_path = "$XDG_CONFIG_HOME/noctalia/templates/picker-palette.json";
                output_path = "$XDG_CONFIG_HOME/noctalia/palettes/current.json";
              };
            };
          };
        };
      };
    };
  };

  # Шаблоны принадлежат Noctalia, а не теме: тема только задаёт палитру.
  xdg.configFile = {
    "noctalia/templates/kcolorscheme.colors".source = ./templates/kcolorscheme.colors;
    "noctalia/templates/picker-palette.json".source = ./templates/picker-palette.json;
  };
}
