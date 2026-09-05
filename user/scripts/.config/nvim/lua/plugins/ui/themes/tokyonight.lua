return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1100,
  config = function()
    vim.o.background = 'dark'
    require('tokyonight').setup(
      {
        style = 'storm'
      }
    )
    vim.cmd.colorscheme('tokyonight')
  end
}
