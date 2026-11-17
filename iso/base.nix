{
  config,
  lib,
  pkgs,
  ...
}:
{
  # ISO — не MagicBook: железные настройки хоста сюда не тащим, но
  # общий слой (локаль, время, звук, Bluetooth, nix, программы) берём из common.

  system = {
    stateVersion = lib.mkForce "26.05";
  };

  boot = {
    zfs = {
      forceImportRoot = lib.mkForce false;
    };
  };

  hardware = {
    # installation-cd-minimal уже включает enableAllHardware; оставляем
    # явно как напоминание, что ISO должен заводиться не только на MagicBook.
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
    tumbler.enable = true;
  };

  security = {
    polkit.enable = true;
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  # Qt-приложения (Telegram и т.п.) должны видеть плагины. Конкретную
  # KDE-тему не навязываем: на live нет Plasma, а qt5ct/kvantum в набор
  # не входят.
  qt = {
    enable = true;
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
