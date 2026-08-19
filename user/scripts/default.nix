{
  lib,
  ...
}:
let
  configDir = "/etc/nixos/user/scripts/.config";
  apps = [
    "hypr"
    "nvim"
    "kitty"
    "fastfetch"
  ];
  linkScript = builtins.concatStringsSep "\n" (
    map
      (app: # bash
        ''
          if [ -d "${configDir}/${app}" ]; then
            if [ -d "$HOME/.config/${app}" ] && [ ! -L "$HOME/.config/${app}" ]; then
              rm -rf "$HOME/.config/${app}"
            fi
            ln -sfn "${configDir}/${app}" "$HOME/.config/${app}"
          fi
        ''
      )
      apps
  );
in
{
  home = {
    activation = {
      linkConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${linkScript}
      '';
    };
  };
}
