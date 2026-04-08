{
  lib,
  ...
}:
{
  programs = {
    fish = {
      functions = {
        uv-nix = ''
          set -l name $argv
          if test -z "$name"
            return 1
          end
          mkdir -p "$name"; and cd "$name"
          printf "%s\n" '${lib.readFile ./templates/uv-flake.nix.tmpl}' > flake.nix
          nix develop
        '';
      };
    };
  };
}
