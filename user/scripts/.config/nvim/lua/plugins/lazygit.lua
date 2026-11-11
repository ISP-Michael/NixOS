local P = require('pack')
local M = {}

function M.open()
  P.use('lazygit.nvim')
  vim.cmd('LazyGit')
end

P.register(
  'lazygit.nvim',
  function()
    P.load('plenary.nvim')
    P.load('lazygit.nvim')
  end
)

vim.keymap.set(
  'n',
  '<leader>lg',
  M.open,
  {
    desc = 'LazyGit'
  }
)

return M
