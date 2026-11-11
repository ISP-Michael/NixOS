local P = require('pack')

P.register(
  'nvim-surround',
  function()
    P.load('nvim-surround')
    require('nvim-surround').setup()
  end
)

-- It only installs mappings.  Load it one tick after the UI is up, so it is
-- not part of the critical startup path but is ready before the first key.
vim.api.nvim_create_autocmd(
  'UIEnter',
  {
    once = true,
    callback = function()
      vim.schedule(
        function()
          P.use('nvim-surround')
        end
      )
    end,
  }
)

return {}
