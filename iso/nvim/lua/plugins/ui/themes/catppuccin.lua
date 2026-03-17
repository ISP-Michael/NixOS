return {
  'catppuccin/nvim',
  name = 'catppuccin',
  dependencies = {
    'aimuzov/catppuccin-barista.nvim'
  },
  lazy = false,
  priority = 1000,
  opts = {
    flavour = 'espresso',
  },
  config = function(_, opts)
    require('catppuccin-barista').setup(
      {
        presets = {
          'espresso',
        }
      },
      opts
    )
    vim.cmd.colorscheme('catppuccin-mocha')
  end,
}
