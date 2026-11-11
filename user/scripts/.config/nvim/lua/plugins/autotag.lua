local P = require('pack')

P.register(
  'nvim-ts-autotag',
  function()
    P.load('nvim-ts-autotag')
    require('nvim-ts-autotag').setup()
  end
)

vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = {
      'html',
      'xml',
      'markdown',
    },
    callback = function()
      P.use('nvim-ts-autotag')
    end,
  }
)

return {}
