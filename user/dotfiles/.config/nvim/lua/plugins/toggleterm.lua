local P = require('pack')

P.register(
  'toggleterm.nvim',
  function()
    P.load('toggleterm.nvim')
    require('toggleterm').setup(
      {
        autochdir = false,
      }
    )
  end
)

return {}
