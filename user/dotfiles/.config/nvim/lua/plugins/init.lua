-- Each module registers a lazy loader/keymap with lua/pack.lua.  Requiring
-- these files is cheap: they do not touch plugin code.
local P = require('pack')

local modules = {
  'plugins.lsp',
  'plugins.treesitter',
  'plugins.gitsigns',
  'plugins.fzf',
  'plugins.neotree',
  'plugins.autopairs',
  'plugins.autotag',
  'plugins.surround',
  'plugins.spectre',
  'plugins.trouble',
  'plugins.lazygit',
  'plugins.dap',
  'plugins.dbee',
  'plugins.toggleterm',
  'plugins.code-runner',
  'plugins.run',
  'plugins.conform',
  'plugins.align',
  'plugins.transparent',
  'plugins.neoscroll',
  'plugins.langmapper',
  'plugins.notify',
  'plugins.lualine',
  'plugins.dependencies',
  'plugins.vim-nix',
}

for _, module in ipairs(modules) do
  require(module)
end

require('plugins.lualine').setup()

return P
