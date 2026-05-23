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
    postgresql = {
      enable = true;
    };
  };
}
