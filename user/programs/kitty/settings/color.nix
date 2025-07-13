{
  lib,
  ...
}:
let
  colors = [
    "#0b0c15"
    "#d2556c"
    "#7cd47b"
    "#efb184"
    "#6ca1f3"
    "#b78df0"
    "#69bcf4"
    "#c0caf5"
    "#39404a"
    "#f7768e"
    "#85e89d"
    "#f4cf8d"
    "#8fb9ff"
    "#d9a3ff"
    "#8fd3ff"
    "#f0f3f6"
  ];
in
{
  programs = {
    kitty = {
      settings = lib.listToAttrs (
        lib.imap1 (i: color: {
          name  = "color${toString (i - 1)}";
          value = color;
        }) colors
      );
    };
  };
}
