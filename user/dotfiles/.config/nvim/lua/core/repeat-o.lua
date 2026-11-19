-- Count-aware o/O: [count]o opens count lines and stays in insert mode on
-- the last one. The old lazy.nvim config required this as core.O_o; the
-- vim.pack refactor dropped the require, so the mapping disappeared.
local function repeat_o(is_upper)
  local count = vim.v.count1
  if count == 1 then
    vim.api.nvim_feedkeys(is_upper and 'O' or 'o', 'n', false)
    return
  end

  local sequence = {}
  for _ = 1, count - 1 do
    sequence[#sequence + 1] = (is_upper and 'O' or 'o') .. '<Esc>'
  end
  sequence[#sequence + 1] = is_upper and 'O' or 'o'

  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(
      table.concat(sequence),
      true,
      false,
      true
    ),
    'n',
    false
  )
end

vim.keymap.set(
  'n',
  'o',
  function()
    repeat_o(false)
  end,
  {
    desc = 'Open line below, repeat count',
  }
)

vim.keymap.set(
  'n',
  'O',
  function()
    repeat_o(true)
  end,
  {
    desc = 'Open line above, repeat count',
  }
)
