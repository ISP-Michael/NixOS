return {
  'xiyaowong/transparent.nvim',
  keys = {
    {
      '<leader>te',
      ':TransparentEnable<cr>'
    },
    {
      '<leader>td',
      ':TransparentDisable<cr>'
    }
  },
  opts = {
    -- flatwhite/flatblack рисуют номер текущей строки инвертированным
    -- (тёмный/светлый чип). Без этого исключения transparent.nvim стирает
    -- фон и номер становится невидимым.
    exclude_groups = { 'CursorLineNr' }
  }
}
