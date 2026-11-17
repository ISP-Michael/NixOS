local function repeat_o(is_upper)
  local count = vim.v.count1
  if count == 1 then
    vim.api.nvim_feedkeys(is_upper and 'O' or 'o', 'n', false)
    return
  end
  local sequence = ''
  for i = 1, count - 1 do
    sequence = sequence .. (is_upper and 'O' or 'o') .. '<Esc>'
  end
  sequence = sequence .. (is_upper and 'O' or 'o')
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(sequence, true, false, true),
    'n',
    false
  )
end

local set = vim.keymap.set
set('n', 'o', function() repeat_o(false) end)
set('n', 'O', function() repeat_o(true)  end)

