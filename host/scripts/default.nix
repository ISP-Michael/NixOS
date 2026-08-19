{
  lib,
  ...
}:
let
  configDir = "/etc/nixos/host/scripts/etc";
  configs = {
    keyd = "/etc/keyd";
  };
  linkScript = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList
      (name:
        target: # bash
          ''
            if [ -d "${configDir}/${name}" ]; then
              if [ -e "${target}" ] && [ ! -L "${target}" ]; then
                rm -rf "${target}"
              fi
              ln -sfn "${configDir}/${name}" "${target}"
            fi
          ''
      )
      configs
  );
in
{
  system = {
    activationScripts = {
      sys-configs = lib.mkAfter ''
        ${linkScript}
      '';
    };
  };
}
