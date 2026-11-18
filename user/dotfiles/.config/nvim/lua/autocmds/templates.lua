-- New-file templates. Each entry keeps the original cursor position and the
-- exact text that used to live in separate python/ and typescript/ modules.
local templates = {
  {
    pattern = '*.py',
    cursor = {
      2,
      4,
    },
    text = [[def main() -> None:
    

if __name__ == '__main__':
    main()
]],
  },
  {
    pattern = '*.ts',
    cursor = {
      4,
      3,
    },
    text = [[import * as readline from 'node:readline';

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
]],
  },
}

local function insert(template)
  local lines = vim.split(
    template.text,
    '\n',
    {
      plain = true,
      trimempty = true,
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
    template.cursor
  )
  vim.cmd('startinsert!')
end

for _, template in ipairs(templates) do
  vim.api.nvim_create_autocmd(
    {
      'BufNewFile',
    },
    {
      pattern = template.pattern,
      callback = function()
        if vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
          insert(template)
        end
      end,
    }
  )
end

return templates
