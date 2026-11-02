vim.g.pyindent_open_paren = vim.o.shiftwidth

-- Закрывающая скобка на отдельной строке должна вставать на уровень строки
-- с открывающей скобкой, а не на уровень последнего аргумента.
vim.g.python_indent = vim.tbl_extend(
  'force',
  vim.g.python_indent or {},
  {
    closed_paren_align_last_line = false
  }
)
