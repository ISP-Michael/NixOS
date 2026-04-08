return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim'
  },
  keys = {
    {
      '<leader>nt',
      ':Neotree<CR>'
    }
  },
  config = function()
    require('neo-tree').setup(
      {
        window = {
          position = 'float',
          size = 40,
          popup_options = {
            border_style = 'rounded',
            col = '50%',
            row = '50%',
            size = {
              width = '80%',
              height = '80%',
            },
          },
        },
      }
    )
  end,
}

