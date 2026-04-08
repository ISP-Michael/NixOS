function Insert_typescript_template()
  local template_text = [[import * as readline from 'node:readline';

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
      4,
      3
    }
  )
  vim.cmd('startinsert!')
end

local function is_buffer_empty()
  return vim.fn.line('$') == 1 and vim.fn.getline(1) == ''
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'typescript',
  callback = function()
    if is_buffer_empty() then
      Insert_typescript_template()
    end
  end,
})

return {
  insert = Insert_typescript_template
}
