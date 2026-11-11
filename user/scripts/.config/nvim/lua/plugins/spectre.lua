local P = require('pack')
local M = {}

function M.toggle()
  P.use('nvim-spectre')
  require('spectre').toggle()
end

function M.open_visual()
  P.use('nvim-spectre')
  require('spectre').open_visual(
    {
      select_word = true
    }
  )
end

P.register(
  'nvim-spectre',
  function()
    P.load('plenary.nvim')
    P.load('nvim-spectre')
    require('spectre').setup(
      {
        is_live = true,
        open_cmd = 'vnew',
      }
    )
  end
)

vim.keymap.set(
  'n',
  '<leader>S',
  M.toggle,
  {
    desc = 'Toggle Spectre (Search and Replace)'
  }
)
vim.keymap.set(
  'n',
  '<leader>sw',
  M.open_visual,
  {
    desc = 'Search current word'
  }
)

return M
