{
  lib,
  pkgs,
  ...
}:
{
  users = {
    users = {
      # Live-пользователь совпадает с хостовым: тогда пути в dotfiles
      # (/home/Michael) и home-manager-конфиг работают без переделок.
      Michael = {
        isNormalUser = true;
        shell = pkgs.zsh;
        initialHashedPassword = "";
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
          "input"
          "render"
          "bluetooth"
        ];
      };
    };
  };

  security = {
    sudo = {
      wheelNeedsPassword = lib.mkForce false;
    };
  };

  services = {
    getty = {
      # greetd сам стартует Hyprland, getty на tty1 только мешает.
      autologinUser = lib.mkForce null;
      helpLine = lib.mkForce "";
    };
  };
}
