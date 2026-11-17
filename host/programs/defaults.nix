{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    steam.enable = true;
    # ccache.enable отключён: обёртка nix-ccache.pl не проходит проверку
    # ensure-wrapper-integrity (nixpkgs #575747).
    # ccache.enable = true;
    virt-manager.enable = true;
    ydotool.enable = true;
    gpu-screen-recorder.enable = true;
  };
}
