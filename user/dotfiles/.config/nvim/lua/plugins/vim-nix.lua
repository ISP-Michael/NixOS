-- vim-nix only provides ftdetect/syntax/indent. Runtime files are enough;
-- sourcing its plugin/ script at startup would be another eager load.
local P = require('pack')

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
