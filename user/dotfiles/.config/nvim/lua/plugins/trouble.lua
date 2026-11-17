local P = require('pack')
local M = {}

function M.toggle()
  P.use('trouble.nvim')
  vim.cmd('Trouble diagnostics toggle')
end

P.register(
  'trouble.nvim',
  function()
    P.load('trouble.nvim')
    require('trouble').setup()
  end
)

vim.keymap.set(
  'n',
  '<leader>xx',
  M.toggle,
  {
    desc = 'Trouble diagnostics'
  }
)

return M
