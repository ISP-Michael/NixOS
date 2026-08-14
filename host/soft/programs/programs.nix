{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fish = {
      enable = true;
      generateCompletions = false;
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
}
