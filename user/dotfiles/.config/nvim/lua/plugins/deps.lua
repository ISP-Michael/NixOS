-- Dependencies have no setup of their own; the loaders make them explicit for
-- :PackLoadAll and for the full-plugin benchmark.
local P = require('pack')

for _, name in ipairs(
  {
    'plenary.nvim',
    'nui.nvim',
    'nvim-nio',
    'nvim-web-devicons',
  }
) do
  P.register(
    name,
    function()
      P.load(name)
    end
  )
end

-- vim-nix only provides ftdetect/syntax/indent.  Runtime files are enough;
-- sourcing its plugin/ script at startup would be another eager load.
P.register(
  'vim-nix',
  function()
    P.runtime('vim-nix')
  end
)
vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = 'nix',
    callback = function()
      P.runtime('vim-nix')
    end,
  }
)

return {}
