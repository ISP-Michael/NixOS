{
  lib,
  ...
}: {
  qt.qt6ctSettings = {
    Fonts.fixed = lib.mkForce ''"FiraCode Nerd Font NDD TG,12"'';
  };
}
