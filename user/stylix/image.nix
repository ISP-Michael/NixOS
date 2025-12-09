{
  self,
  pkgs,
  ...
}:
{
  stylix = {
    # image = "${self}/dependencies/images/siber_true.png";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };
}
