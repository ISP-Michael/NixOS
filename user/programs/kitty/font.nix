{ pkgs, ... }:
{
  programs = {
    kitty = {
      font = {
        package = pkgs.nerd-fonts.ubuntu-mono;
        name    = "FiraCodeRoman-Regular";
        size    = 12;
      };
    };
  };
}
