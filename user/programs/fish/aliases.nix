{
  lib,
  ...
}:
{
  programs = {
    fish = {
      shellAliases = lib.recursiveUpdate (import ../shell-aliases.nix) {
        gs = "git status -s";
        efuzzy = "nvim (fzf || echo '-c q')";
      };
    };
  };
}
