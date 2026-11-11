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

if vim.g.neovide ~= nil then
  vim.opt.autochdir = true
end

require('vim._core.ui2').enable(
  {

  }
)

require('pack').setup()

require('core.options')
require('core.indent')
require('core.keymap')
require('core.diagnostic')
require('core.completion')
require('core.py')

require('autocmds.python_template')
require('autocmds.typescript_template')

-- Registers keymaps/events only; plugin code stays on disk until first use.
require('plugins')

require('plugins.lualine').setup()

vim.o.background = 'dark'
vim.cmd.colorscheme('flatblack')
