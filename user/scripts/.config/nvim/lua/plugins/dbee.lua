local P = require('pack')

P.register(
  'nvim-dbee',
  function()
    P.load('nui.nvim')
    P.load('nvim-dbee')
    require('dbee').setup()
  end
)

vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = 'sql',
    callback = function()
      P.use('nvim-dbee')
    end,
  }
)

return {}
