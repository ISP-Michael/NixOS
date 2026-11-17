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
    # ccache.enable отключён: обёртка nix-ccache.pl не проходит проверку ensure-wrapper-integrity (nixpkgs #575747)
    # ccache.enable = true;
    virt-manager.enable = true;
    ydotool.enable = true;
    gamemode.enable = true;
    gpu-screen-recorder.enable = true;
  };
  qt = {
    enable = true;
    platformTheme = "kde";
    style = "breeze";
  };
  systemd.tmpfiles.settings."10-noctalia-chromium" = {
    "/etc/chromium/policies/managed".d = {
      mode = "0755";
    };
    "/etc/chromium/policies/managed/noctalia-color.json".f = {
      user = "Michael";
      group = "users";
      mode = "0644";
      argument = "{}";
    };
  };
}
