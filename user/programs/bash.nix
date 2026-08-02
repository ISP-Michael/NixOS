{
  lib,
  ...
}:
{
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = lib.recursiveUpdate (import ./shell-aliases.nix) {
        gs = "git status";
      };
      initExtra = ''
        set -o vi
      '';
    };
  };
}
