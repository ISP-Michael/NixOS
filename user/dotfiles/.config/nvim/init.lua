vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Neovim probes these interpreters on the first Python/Ruby/Perl/Node buffer.
-- The probe alone costs ~100 ms on a Python file and nothing here uses
-- :python3 / :ruby / :perl / :node.
vim.g.loaded_python3_provider = 1
vim.g.loaded_ruby_provider = 1
vim.g.loaded_perl_provider = 1
vim.g.loaded_node_provider = 1

-- Bytecode cache for every Lua module required below (~/.cache/nvim/luac).
vim.loader.enable()

-- Experimental message/cmdline UI from nvim 0.13. Internal API; pin the
-- nightly and recheck messages/cmdline after an upgrade.
require('vim._core.ui2').enable(
  {

  }
)

require('pack').setup()

require('core.options')
require('core.syntax')
require('core.indent')
require('core.keymap')
require('core.repeat-o')
require('core.diagnostic')
require('core.completion')
require('core.python')

require('core.project').setup()
if vim.g.neovide then
  require('core.neovide').setup()
end

require('autocmds.templates')

-- Registers keymaps/events only; plugin code stays on disk until first use.
-- The manifest also configures lualine, so init.lua stays plugin-free.
require('plugins')

require('core.theme-sync').setup()
