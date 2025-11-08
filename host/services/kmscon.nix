{ pkgs, ... }:
{
  services = {
    kmscon = {
      enable = true;
      fonts = [
        {
          name = "FiraCodeRoman-Regular";
          package = pkgs.nerd-fonts.fira-code;
        }
      ];
    };
  };
}
