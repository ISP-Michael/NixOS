{
  pkgs,
  ...
}:
{
  system = {
    stateVersion = "26.05";
  };
  hardware = {
    bluetooth = {
      enable = true;
    };
  };
  services = {
    udev = {
      # MTP по USB: правила libmtp определяют телефон, uaccess даёт доступ
      # текущему пользователю (Dolphin/kio-mtp).
      packages = [
        pkgs.libmtp
      ];
      extraRules = ''
        ACTION=="add", SUBSYSTEM=="usb", ENV{ID_MTP_DEVICE}=="1", TAG+="uaccess"
      '';
    };
  };
}
