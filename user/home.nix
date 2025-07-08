{
  pkgs,
  self,
  ...
}:
let
  pythonEnv13 = pkgs.python313.withPackages(
    ps: with ps; [
      cython
      django
      fastapi
      fastapi-cli
      nox
      nuitka
      numpy
      pandas
      pillow
      requests
    ]
  );
in
{
  home = {
    username = "Michael";
    stateVersion = "25.05";
    homeDirectory = "/home/Michael";
    sessionVariables = {
      EDITOR = "nvim";
      NIXOS_OZONE_WL = "1";
      KDE_NO_OPENGL_WINDOW_DECORATION = "1";
      QT_WAYLAND_DISABLE_WINDOW_DECORATION = "1";
    };
    packages = with pkgs; [
      imv
      libsForQt5.qtstyleplugins
      mpv
      nautilus
      neovim
      pythonEnv13
      telegram-desktop
      xfce.thunar
    ];
    file = {
      ".local/share/fonts/literata" = {
        source = "${self}/dependencies/fonts/Literata";
        recursive = true;
      };
    };
  };
}
