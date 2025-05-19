{
  config,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number
      colorscheme habamax
    '';
    plugins = with pkgs.vimPlugins; [
      vim-nix
      nvim-treesitter
    ];
  };
}
