{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../host/console.nix
    ../host/system/system.nix
    ../host/time.nix
    ../host/services/pipewire.nix
    ../host/settings/experimental-features.nix
    ../host/settings/cache.nix
    ../host/soft/programs/appimage.nix
    ../host/soft/programs/nix-ld.nix
    ../host/soft/programs/dconf.nix
    ../host/systemd.nix
  ];

  # ISO не должен тащить железные настройки MagicBook, но базовые
  # вещи (локаль, время, звук, bluetooth, nix) берём из хостового конфига.
  system = {
    stateVersion = lib.mkForce "26.05";
  };

  boot = {
    zfs = {
      forceImportRoot = lib.mkForce false;
    };
  };

  hardware = {
    # installation-cd-base уже включает enableAllHardware, здесь это
    # напоминание: ISO должен заводиться не только на MagicBook.
    enableAllHardware = true;
    graphics.enable = true;
  };

  # 6 ГБ ОЗУ — live-системе нужен zram, иначе браузер и офис упираются
  # в swap на флешке.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services = {
    udisks2.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    blueman.enable = true;
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      enableGlobalCompInit = false;
    };
  };

  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  environment = {
    etc."zshenv.local".text = ''
      export ZDOTDIR="$HOME/.config/zsh"
    '';
    sessionVariables = {
      GTK_USE_PORTAL = "1";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  fonts = {
    # installation-cd-minimal принудительно выключает fontconfig,
    # для рабочего стола это не годится.
    fontconfig.enable = lib.mkForce true;
    packages = with pkgs; [
      dejavu_fonts
      liberation_ttf
      nerd-fonts.fira-code
      noto-fonts
    ];
  };

  # На live-системе man-страницы полезны, HTML-документацию NixOS
  # можно не тащить — она занимает место.
  documentation = {
    nixos.enable = lib.mkForce false;
    doc.enable = lib.mkForce false;
  };

  # Минимальный установщик ставит edition = "minimal"; для профилей
  # хотим видеть в названии ISO, что именно собрано.
  isoImage = {
    edition = lib.mkForce "iso-${config.iso.profile}";
    # 6 ГБ ОЗУ: zstd 19 на 4-гигабайтном squashfs упирается в память.
    squashfsCompression = lib.mkForce "zstd -Xcompression-level 15";
  };
}
