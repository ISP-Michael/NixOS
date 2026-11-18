local P = require('pack')
local M = {}

function M.run()
  P.use('toggleterm.nvim')
  P.use('code_runner.nvim')
  vim.cmd('RunCode')
end

vim.keymap.set(
  {
    'v',
    'n',
  },
  '<leader>rc',
  M.run,
  {
    desc = 'Run code',
  }
)

return M
