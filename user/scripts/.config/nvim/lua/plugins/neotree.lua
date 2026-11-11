local P = require('pack')
local M = {}

function M.open()
  P.use('neo-tree.nvim')
  vim.cmd('Neotree')
end

P.register(
  'neo-tree.nvim',
  function()
    P.load('plenary.nvim')
    P.load('nui.nvim')
    P.load('nvim-web-devicons')
    P.load('neo-tree.nvim')
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
  end
)

vim.keymap.set(
  'n',
  '<leader>nt',
  M.open,
  {
    desc = 'Neo-tree'
  }
)

return M
