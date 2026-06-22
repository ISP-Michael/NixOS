{
  inputs,
  unstable-pkgs,
  git-pkgs,
  pkgs,
  ...
}:
{
  # imports = [
  #   "${inputs.nixos-unstable}/nixos/modules/programs/throne.nix"
  # ];
  # disabledModules = [
  #   "programs/throne.nix"
  # ];
  programs = {
    throne = {
      enable = true;
      # package = unstable-pkgs.throne;
      tunMode = {
        enable = true;
        setuid = true;
      };
    };
  };
}
