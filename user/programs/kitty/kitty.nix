let
  sb = builtins.concatStringsSep " " [
    "FiraCodeRoman-SemiBold"
    "ss01 ss03 ss06 ss07 ss10"
    "cv02 cv18 cv25 cv26 cv27 cv29 cv30 cv32"
    "zero"
  ];
  r = builtins.concatStringsSep " " [
    "FiraCodeRoman-Regular"
    "ss01 ss03 ss06 ss07 ss10"
    "cv02 cv18 cv25 cv26 cv27 cv29 cv30 cv32"
    "zero"
  ];
in
{
  programs = {
    kitty = {
      enable = true;
      enableGitIntegration = true;
      extraConfig = ''
        font_features ${r}
        font_features ${sb}
      '';
    };
  };
}
