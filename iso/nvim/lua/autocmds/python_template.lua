function Insert_python_template()
  local template_text = [[#!/usr/bin/env python3
def main() -> None:
    


if __name__ == '__main__':
    main()
]]

  vim.api.nvim_buf_set_lines(
    0,
    0,
    -1,
    false,
    vim.split(template_text, '\n')
  )
  vim.api.nvim_win_set_cursor(
    0,
    {
      5,
      4
    }
  )
  vim.cmd('startinsert!')
end

local function is_buffer_empty()
  return vim.fn.line('$') == 1 and vim.fn.getline(1) == ''
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    if is_buffer_empty() then
      Insert_python_template()
    end
  end,
})

return {
  insert = Insert_python_template
}
