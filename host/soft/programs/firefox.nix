{ pkgs, ... }:
{
  programs = {
    firefox = with pkgs; {
      enable  = true;
      package = firefox;
    };
  };
}
