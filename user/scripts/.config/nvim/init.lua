local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system(
    {
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable',
      lazypath,
    }
  )
end
vim.opt.rtp:prepend(lazypath)

if vim.g.neovide ~= nil then
  vim.opt.autochdir = true
end


require('vim._core.ui2').enable(
  {

  }
)
require('core.options')
require('core.indent')
require('core.keymap')
require('core.diagnostic')
require('lazy').setup(
  'plugins',
  {
    reset_packpath = true,
    rtp = {
      reset = true
    }
  }
)
require('core.O_o')
require('core.py')
require('autocmds.python_template')
require('autocmds.typescript_template')

