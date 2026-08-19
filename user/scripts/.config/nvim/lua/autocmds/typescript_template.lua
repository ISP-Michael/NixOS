local template = [[import * as readline from 'node:readline';

function main(): undefined {
  
}

const rl = readline.createInterface(
  {
    input: process.stdin,
    output: process.stdout
  }
);

rl.question(
  '', (line) => {
    main();
    rl.close();
  }
)
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
      4,
      3
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
      '*.ts'
    },
    callback = function()
      if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
        M.insert()
      end
    end
  }
)

return M
