{
  identity,
  lib,
  ...
}:
let
  configDir = "${identity.repoPath}/user/dotfiles/.config";
  apps = [
    "hypr"
    "nvim"
    "kitty"
    "fastfetch"
    "tmux"
    "zsh"
    "yazi"
  ];
  linkScript = builtins.concatStringsSep "\n" (
    map
      (app: # bash
        ''
          if [ -d "${configDir}/${app}" ]; then
            if [ -d "$HOME/.config/${app}" ] && [ ! -L "$HOME/.config/${app}" ]; then
              mv "$HOME/.config/${app}" "$HOME/.config/${app}.bak-$(date +%Y%m%d-%H%M%S)"
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
