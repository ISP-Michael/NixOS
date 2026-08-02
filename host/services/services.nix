{
  lib,
  ...
}:
let
  enabledDefaults = lib.genAttrs [
    "blueman"
    "libinput"
    "udisks2"
  ]
  (name: {
      enable = true;
    }
  );
in
{
  services = enabledDefaults // {
    gvfs.enable = true;
    postgresql.enable = true;
    upower.enable = true;
  };
}
