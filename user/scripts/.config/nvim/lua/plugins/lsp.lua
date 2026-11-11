-- First file: resolve server configs and install the completion/LspAttach
-- handlers.  Nothing in vim.lsp is touched while Neovim starts without a file.
local P = require('pack')

local loaded = false

local function setup()
  if loaded then
    return
  end
  loaded = true
  P.runtime('nvim-lspconfig')
  require('core.lsp').setup()
end

P.register('nvim-lspconfig', setup)

vim.api.nvim_create_autocmd(
  'FileType',
  {
    once = true,
    callback = setup,
  }
)

return {}
