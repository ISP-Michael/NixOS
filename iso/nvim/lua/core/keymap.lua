local set = vim.keymap.set
set('n', '<C-s>',  ':w<CR>')
set('n', '<C-q>',  ':q<CR>')
set('n', '<Esc>',  ':nohlsearch<cr>')
-- set('t', '<C-w>k', '<C-\\><C-n><C-w>k')
set(
  'n',
  '<leader>dq',
  function()
    require('dap').terminate()
    require('dapui').close()
  end
)

local buf = vim.lsp.buf
set('n', 'gd', buf.definition)
set('n', 'gD', buf.declaration)
set('n', 'K',  buf.hover)


