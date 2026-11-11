local P = require('pack')

P.register(
  'nvim-autopairs',
  function()
    P.load('nvim-autopairs')
    require('nvim-autopairs').setup()
  end
)

vim.api.nvim_create_autocmd(
  'InsertEnter',
  {
    once = true,
    callback = function()
      P.use('nvim-autopairs')
    end,
  }
)

return {}
