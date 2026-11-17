local P = require('pack')

P.register(
  'neoscroll.nvim',
  function()
    P.load('neoscroll.nvim')
    require('neoscroll').setup({})
  end
)

-- Replace the default scroll mappings a tick after the UI appears.  Startup
-- stays clean and the first scroll key still finds a configured plugin.
vim.api.nvim_create_autocmd(
  'UIEnter',
  {
    once = true,
    callback = function()
      vim.schedule(
        function()
          P.use('neoscroll.nvim')
        end
      )
    end,
  }
)

return {}
