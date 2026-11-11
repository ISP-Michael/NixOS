local P = require('pack')
local M = {}

function M.enable()
  P.use('transparent.nvim')
  vim.cmd('TransparentEnable')
end

function M.disable()
  P.use('transparent.nvim')
  vim.cmd('TransparentDisable')
end

P.register(
  'transparent.nvim',
  function()
    P.load('transparent.nvim')
    require('transparent').setup(
      {
        -- flatwhite/flatblack рисуют номер текущей строки инвертированным
        -- (тёмный/светлый чип). Без этого исключения transparent.nvim стирает
        -- фон и номер становится невидимым.
        exclude_groups = {
          'CursorLineNr'
        }
      }
    )
  end
)

vim.keymap.set(
  'n',
  '<leader>te',
  M.enable,
  {
    desc = 'Transparent: enable'
  }
)
vim.keymap.set(
  'n',
  '<leader>td',
  M.disable,
  {
    desc = 'Transparent: disable'
  }
)

return M
