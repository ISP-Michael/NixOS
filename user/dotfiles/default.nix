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
    ++ [
      # OpenCode: каталог ~/.config/opencode остаётся реальным (opencode.jsonc,
      # service.json, node_modules), но общие файлы — симлинки в dotfiles.
      # Старый путь user/scripts/.config после рефактора 17.11 мёртв.
      ''
        mkdir -p "$HOME/.config/opencode"
        ln -sfn "${configDir}/opencode/cli.json" "$HOME/.config/opencode/cli.json"
        ln -sfn "${configDir}/opencode/package.json" "$HOME/.config/opencode/package.json"
        ln -sfn "${configDir}/opencode/plugins" "$HOME/.config/opencode/plugins"
      ''
    ]
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
