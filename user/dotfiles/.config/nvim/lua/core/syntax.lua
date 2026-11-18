-- after/syntax links are wiped by `hi clear` during a colourscheme change.
-- Re-apply them for the current buffer so gitignore highlighting survives
-- flatblack <-> flatwhite switches.
vim.api.nvim_create_autocmd(
  'ColorScheme',
  {
    callback = function()
      if vim.bo.filetype == 'gitignore' then
        vim.cmd('runtime! after/syntax/gitignore.vim')
      end
    end,
  }
)
