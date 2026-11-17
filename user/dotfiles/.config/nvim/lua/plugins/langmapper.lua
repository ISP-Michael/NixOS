local P = require('pack')

P.register(
  'langmapper.nvim',
  function()
    P.load('langmapper.nvim')
    require('langmapper').setup()
  end
)

-- It monkey-patches vim.keymap.set, so it must run after our own mappings are
-- registered.  UIEnter is the native replacement for lazy.nvim's VeryLazy.
vim.api.nvim_create_autocmd(
  'UIEnter',
  {
    once = true,
    callback = function()
      vim.schedule(
        function()
          P.use('langmapper.nvim')
        end
      )
    end,
  }
)

return {}
