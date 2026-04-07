local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

if vim.g.neovide ~= nil then
  vim.opt.autochdir = true
end


vim.loader.enable()
-- vim.cmd('colorscheme flatwhite')
require('core.options')
require('core.indent')
require('core.keymap')
require('core.diagnostic')
require('lazy').setup('plugins', {
  performance = {
    enabled = true,
    path = vim.fn.stdpath('cache') .. '/lazy/cache',
    reset_on_startup = 'always'
  },
  reset_packpath = true,
  rtp = {
    reset = false
  }
})
require('core.O_o')
require('core.py')
require('autocmds.python_template')
require('autocmds.typescript_template')


function Insert_template_based_on_filetype()
  local filetype = vim.bo.filetype
  if filetype == 'python' then
    require('autocmds.python_template').insert()
  elseif filetype == 'typescript' then
    require('autocmds.typescript_template').insert()
  else
    print("Для текущего filetype (" .. filetype .. ") шаблон не определен.")
  end
end

vim.api.nvim_set_keymap('n', '<Leader>pt',
  [[<Cmd>lua Insert_template_based_on_filetype()<CR>]],
  {
    noremap = true,
    silent = true
  }
)

