local P = require('pack')
local M = {}

function M.run()
  P.use('toggleterm.nvim')
  P.use('code_runner.nvim')
  vim.cmd('RunCode')
end

P.register(
  'toggleterm.nvim',
  function()
    P.load('toggleterm.nvim')
    require('toggleterm').setup(
      {
        autochdir = false
      }
    )
  end
)

P.register(
  'code_runner.nvim',
  function()
    P.load('code_runner.nvim')
    require('code_runner').setup(
      {
        filetype = {
          python = 'python3 -u',
          javascript = 'node',
          typescript = 'node',
          rust = 'cargo run',
          cpp = 'g++ -std=c++20 $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt',
          cs = 'dotnet run',
          go = 'go run'
        },
        mode = 'toggleterm'
      }
    )
  end
)

vim.keymap.set(
  {
    'v',
    'n'
  },
  '<leader>rc',
  M.run,
  {
    desc = 'Run code'
  }
)

return M
