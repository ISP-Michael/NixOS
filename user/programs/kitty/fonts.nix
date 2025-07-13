{ pkgs, ... }:
{
  programs = {
    kitty = {
      font = {
        package = pkgs.nerd-fonts.fira-code;
        name    = "FiraCodeRoman-Regular";
        size    = 12;
      };
    };
  };
}
