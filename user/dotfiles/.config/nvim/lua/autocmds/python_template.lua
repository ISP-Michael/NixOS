local template = [[def main() -> None:
    

if __name__ == '__main__':
    main()
]]

local M = {}

function M.insert()
  local lines = vim.split(
    template,
    '\n',
    {
      plain = true,
      trimempty = true
    }
  )
  vim.api.nvim_buf_set_lines(
    0,
    0,
    -1,
    false,
    lines
  )
  vim.api.nvim_win_set_cursor(
    0,
    {
      2,
      4
    }
  )
  vim.cmd('startinsert!')
end

vim.api.nvim_create_autocmd(
  {
    'BufNewFile'
  },
  {
    pattern = {
      '*.py'
    },
    callback = function()
      if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
        M.insert()
      end
    end
  }
)

return M
