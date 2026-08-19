{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    zsh = {
      enable = true;
      enableGlobalCompInit = false;
    };
    steam.enable = true;
    ccache.enable = true;
    virt-manager.enable = true;
    ydotool.enable = true;
    gamemode.enable = true;
    gpu-screen-recorder.enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };
}
