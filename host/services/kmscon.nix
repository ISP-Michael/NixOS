{ pkgs, ... }:
{
  services = {
    kmscon = {
      enable = true;
      fonts.fira = {
        name = "FiraCodeRoman-Regular";
        src  = pkgs.nerd-fonts.fira-code;
      };
    };
  };
}
