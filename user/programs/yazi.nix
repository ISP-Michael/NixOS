{ pkgs, ... }:
let
  glow-plugin = pkgs.fetchFromGitHub {
    owner  = "Reledia";
    repo   = "glow.yazi";
    rev    = "2da96e3ffd9cd9d4dd53e0b2636f83ff69fe9af0";
    sha256 = "1ja5xskfy9xinbr37k5a5dpbz1cm3cdmk1vxjyknja9zhn9xqjp2";
  };
  office-plugin = pkgs.fetchFromGitHub {
    owner  = "macydnah";
    repo   = "office.yazi";
    rev    = "d1e3e51857c109fbfc707ab0f9f383dc98b9795f";
    sha256 = "13a7wjsssnavwhq4x5lnfcgs8l0s3w1cscl23gxidvjzxp31w5rr";
  };
  eza-preview-plugin = pkgs.fetchFromGitHub {
    owner  = "ahkohd";
    repo   = "eza-preview.yazi";
    rev    = "6575a9a4806d8dc96ac75adf28791155551804fb";
    sha256 = "1wngkzqkvkm0aifx8bfdg16m3wlv2865m3w1ahb3qp8yki78g66v";
  };
in
{
  programs.yazi = {
    enable = true;
    plugins = with pkgs.yaziPlugins; {
      chmod        = chmod;
      piper        = piper;
      full-border  = full-border;
      rich-preview = rich-preview;
      glow         = "${glow-plugin}";
      office       = "${office-plugin}";
      eza-preview  = "${eza-preview-plugin}";  # Inside is not main.lua, but init.lua
    };
    initLua = ''
      require('piper')
      require('office')
      require('rich-preview')
      require('chmod')
      require('glow')
      require('full-border'):setup({
        type = ui.Border.ROUNDED
      })
    '';
    keymap = {
      manager.prepend_keymap = [
        {
          on   = [ "c" "m" ];
          run  = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };
  };
  xdg.configFile."yazi/yazi.toml".text = ''
    [plugin]
    prepend_previewers = [
      { name = "*.md", run = "glow" },
    ]
  '';
}
