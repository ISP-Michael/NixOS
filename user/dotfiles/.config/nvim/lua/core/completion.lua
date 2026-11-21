-- Completion documentation window.
--
-- The native side popup next to the completion menu is intentionally disabled
-- (`completeopt` has no `popup`): it has no room for a proper separator, wraps
-- long signatures mid-token and can leave stale windows behind.  Full
-- documentation is shown on demand with <C-k>.  Small docs sit in a narrow,
-- tall window beside the menu; big docs get a centered fzf-like overlay with
-- a dimmed backdrop so they are never squeezed into the side strip.
local M = {}

local group = vim.api.nvim_create_augroup('CompletionDocs', { clear = true })
local docs_buf = nil
local docs_win = nil
local scrim_buf = nil
local scrim_win = nil
local docs_generation = 0
local docs_overlay = false
local pending_pum = nil
local hiding_pum = false
local overlay_keymaps = {}

local function clear_overlay_keymaps()
  for _, map in ipairs(overlay_keymaps) do
    pcall(vim.keymap.del, 'i', map.lhs, { buffer = map.bufnr })
  end
  overlay_keymaps = {}
end

local function close_float_buffer(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= '' and vim.api.nvim_win_get_buf(win) == buf then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
end

local function close_docs()
  -- Close every window that shows the docs or scrim buffer.  Tracking a
  -- single window handle is not enough: an old window may survive a selection
  -- change and then stay on screen until Neovim exits.
  local was_overlay = docs_overlay
  docs_overlay = false
  clear_overlay_keymaps()
  close_float_buffer(docs_buf)
  close_float_buffer(scrim_buf)
  if docs_win and vim.api.nvim_win_is_valid(docs_win) then
    pcall(vim.api.nvim_win_close, docs_win, true)
  end
  if scrim_win and vim.api.nvim_win_is_valid(scrim_win) then
    pcall(vim.api.nvim_win_close, scrim_win, true)
  end
  docs_win = nil
  scrim_win = nil
  return was_overlay
end

local function docs_visible()
  if docs_win and vim.api.nvim_win_is_valid(docs_win) then
    return true
  end
  if docs_buf and vim.api.nvim_buf_is_valid(docs_buf) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local cfg = vim.api.nvim_win_get_config(win)
      if cfg.relative ~= '' and vim.api.nvim_win_get_buf(win) == docs_buf then
        return true
      end
    end
  end
  return false
end

local function selected_info()
  local ci = vim.fn.complete_info({
    'items',
    'selected'
  })
  local selected = ci.selected
  if selected < 0 or not ci.items or not ci.items[selected + 1] then
    return nil
  end
  local item = ci.items[selected + 1]
  local info = item.info
  if type(info) == 'table' then
    info = info.value
  end
  if not info or info == '' then
    local lsp = vim.tbl_get(item, 'user_data', 'nvim', 'lsp', 'completion_item')
    local doc = lsp and lsp.documentation
    if type(doc) == 'table' then
      doc = doc.value
    end
    info = doc
  end
  return info
end

-- Remember the popup menu so it can be hidden for the modal overlay and then
-- restored with the same items and selection.
local function snapshot_pum()
  if vim.fn.pumvisible() ~= 1 then
    return nil
  end
  local ci = vim.fn.complete_info({
    'items',
    'selected'
  })
  if not ci.items or #ci.items == 0 or ci.selected < 0 then
    return nil
  end
  local cursor = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local startcol = line:sub(1, cursor):match('()%w*$')
  if not startcol then
    return nil
  end
  return {
    items = ci.items,
    selected = ci.selected,
    startcol = startcol,
    line = line
  }
end

local function hide_pum()
  pending_pum = snapshot_pum()
  if not pending_pum then
    return false
  end
  hiding_pum = true
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<C-e>', true, false, true),
    'n',
    false
  )
  return true
end

local function restore_pum()
  local saved = pending_pum
  pending_pum = nil
  hiding_pum = false
  if not saved then
    return
  end
  vim.fn.complete(saved.startcol, saved.items)
  if saved.selected > 0 then
    local key = vim.api.nvim_replace_termcodes('<C-n>', true, false, true)
    vim.api.nvim_feedkeys(string.rep(key, saved.selected), 'n', false)
  end
end

local function cancel_pum()
  pending_pum = nil
  hiding_pum = false
end

local function display_width(text)
  return vim.fn.strdisplaywidth(text)
end

-- Split a word that is wider than the window, but keep two-character tokens
-- such as `->`, `=>` or `::` on the same line.
local function hard_split(word, width)
  local chunks = {}
  local rest = word
  while rest ~= '' do
    local chars = vim.fn.strchars(rest)
    local cells = 0
    local n = 0
    for i = 1, chars do
      local ch = vim.fn.strcharpart(rest, i - 1, 1)
      local w = display_width(ch)
      if cells + w > width then
        break
      end
      cells = cells + w
      n = i
    end
    if n >= chars then
      chunks[#chunks + 1] = rest
      break
    end
    if n == 0 then
      n = 1
    end
    local last = vim.fn.strcharpart(rest, n - 1, 1)
    local next_ch = vim.fn.strcharpart(rest, n, 1)
    if n > 1 and last:find('[-=:<>!+*/&|%%^]') and next_ch:find('[=>:]') then
      n = n - 1
    end
    chunks[#chunks + 1] = vim.fn.strcharpart(rest, 0, n)
    rest = vim.fn.strcharpart(rest, n)
  end
  return chunks
end

-- Greedy word wrap.  Breaking only at spaces keeps signatures readable and
-- never turns `->` into `-` + `>` on two lines.
local function wrap_line(line, width)
  if line == '' then
    return { '' }
  end
  if display_width(line) <= width then
    return { line }
  end

  local indent = line:match('^(%s*)') or ''
  local indent_width = display_width(indent)
  local lines = {}
  local current = indent
  local current_width = indent_width
  local has_word = false

  local function flush()
    lines[#lines + 1] = current
    current = indent
    current_width = indent_width
    has_word = false
  end

  for word in line:gmatch('%S+') do
    local word_width = display_width(word)
    local extra = has_word and 1 or 0
    if current_width + extra + word_width <= width then
      if has_word then
        current = current .. ' ' .. word
        current_width = current_width + 1 + word_width
      else
        current = current .. word
        current_width = current_width + word_width
        has_word = true
      end
    else
      if has_word then
        flush()
      end
      if indent_width + word_width <= width then
        current = indent .. word
        current_width = indent_width + word_width
        has_word = true
      else
        local chunks = hard_split(word, math.max(1, width - indent_width))
        for i = 1, #chunks do
          if i == #chunks then
            current = indent .. chunks[i]
            current_width = indent_width + display_width(chunks[i])
            has_word = true
          else
            lines[#lines + 1] = indent .. chunks[i]
          end
        end
      end
    end
  end
  if has_word then
    lines[#lines + 1] = current
  end
  return lines
end

local function wrap_doc(raw, width)
  local text_width = math.max(1, width - 2)
  local lines = {}
  for _, line in ipairs(raw) do
    for _, part in ipairs(wrap_line(line, text_width)) do
      lines[#lines + 1] = ' ' .. part
    end
  end
  return lines
end

local function decode_html(text)
  return (
    text:gsub('&lt;', '<')
      :gsub('&gt;', '>')
      :gsub('&quot;', '"')
      :gsub('&#39;', "'")
      :gsub('&#x27;', "'")
      :gsub('&nbsp;', ' ')
      :gsub('&amp;', '&')
  )
end

local function decode_markdown(text)
  -- LSP docs are markdown; drop escapes such as `\_\_str\_\_` in plain text.
  return (text:gsub('\\([\\`*_{}%[%]()#+!|>.%-])', '%1'))
end

local function doc_lines(info)
  local raw = vim.split(info, '\n', { plain = true })
  local cleaned = {}
  for _, line in ipairs(raw) do
    line = decode_markdown(decode_html(line))
    local trimmed = line:match('^%s*(.-)%s*$')
    -- Code fence markers are markdown noise in a plain text preview.
    if trimmed:sub(1, 3) ~= '```' then
      cleaned[#cleaned + 1] = line:gsub('%s+$', '')
    end
  end
  while #cleaned > 0 and cleaned[1] == '' do
    table.remove(cleaned, 1)
  end
  while #cleaned > 0 and cleaned[#cleaned] == '' do
    table.remove(cleaned)
  end
  return cleaned
end

-- Close from a scheduled callback: completion autocmds run with textlock,
-- where closing a window fails silently under pcall and leaves it on screen.
local function schedule_close()
  local generation = docs_generation
  vim.schedule(function()
    if generation == docs_generation then
      close_docs()
    end
  end)
end

-- fzf-like backdrop for large documentation: a full-screen translucent layer
-- that dims the menu and the code behind the centered docs window.
local function open_scrim()
  if not scrim_buf or not vim.api.nvim_buf_is_valid(scrim_buf) then
    scrim_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[scrim_buf].buftype = 'nofile'
    vim.bo[scrim_buf].bufhidden = 'hide'
    vim.bo[scrim_buf].swapfile = false
  end

  local normal = vim.api.nvim_get_hl(0, { name = 'Normal' })
  local bg = normal.bg or 0x000000
  vim.api.nvim_set_hl(0, 'CompletionScrim', {
    fg = bg,
    bg = bg
  })

  scrim_win = vim.api.nvim_open_win(
    scrim_buf,
    false,
    {
      relative = 'editor',
      row = 0,
      col = 0,
      width = vim.o.columns,
      height = vim.o.lines - vim.o.cmdheight,
      style = 'minimal',
      focusable = false,
      noautocmd = true,
      zindex = 55
    }
  )
  vim.wo[scrim_win].winhighlight = 'Normal:CompletionScrim'
  vim.wo[scrim_win].winblend = 50
  vim.wo[scrim_win].wrap = false
  vim.wo[scrim_win].cursorline = false
  vim.wo[scrim_win].number = false
  vim.wo[scrim_win].relativenumber = false
  vim.wo[scrim_win].signcolumn = 'no'
  vim.wo[scrim_win].foldcolumn = '0'
  vim.wo[scrim_win].spell = false
end

local function feed_key(key, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(key, true, false, true),
    mode or 'n',
    false
  )
end

local function leave_overlay_and(key, remap)
  close_docs()
  restore_pum()
  feed_key(key, remap and 'm' or 'n')
end

-- Buffer-local keys while the modal overlay is open.  Enter is replayed with
-- remapping so autopairs' global <CR> mapping accepts the restored item; the
-- arrows only navigate the restored menu.
local function set_overlay_keymaps()
  clear_overlay_keymaps()
  local bufnr = vim.api.nvim_get_current_buf()
  local function add(lhs, key, remap)
    vim.keymap.set(
      'i',
      lhs,
      function()
        leave_overlay_and(key, remap)
      end,
      {
        buffer = bufnr,
        nowait = true,
        desc = 'Completion docs: close and continue'
      }
    )
    overlay_keymaps[#overlay_keymaps + 1] = {
      lhs = lhs,
      bufnr = bufnr
    }
  end
  add('<CR>', '<CR>', true)
  add('<Tab>', '<Tab>', true)
  add('<S-Tab>', '<S-Tab>', true)
  add('<C-n>', '<C-n>', false)
  add('<C-p>', '<C-p>', false)
  add('<Down>', '<Down>', false)
  add('<Up>', '<Up>', false)
end

local function show_docs()
  close_docs()
  cancel_pum()

  local info = selected_info()
  if not info or info == '' then
    return
  end

  local raw = doc_lines(info)
  if #raw == 0 then
    return
  end

  local max_width = 0
  for _, line in ipairs(raw) do
    max_width = math.max(max_width, display_width(line))
  end

  -- Small docs sit beside the menu in a narrow column.  When the text is too
  -- large for that column (or there is no room next to the menu), use a big
  -- centered fzf-like overlay with a dimmed backdrop instead of squeezing it.
  local narrow_width = math.min(math.max(max_width + 2, 40), 64)
  local pum = vim.fn.pum_getpos()
  local margin = 2
  local width, row, col, lines, height
  local overlay = false

  if pum and pum.width and pum.width > 0 then
    local right_col = pum.col + pum.width + margin
    local right_space = vim.o.columns - right_col - 2
    local left_space = pum.col - margin - 2
    local side_col
    if right_space >= narrow_width then
      side_col = right_col
    elseif left_space >= narrow_width then
      side_col = pum.col - margin - narrow_width
    end

    local side_lines = wrap_doc(raw, narrow_width)
    local side_too_large = max_width > 100
      or #side_lines > math.max(12, math.floor(vim.o.lines * 0.45))
    local side_max_height = vim.o.lines - pum.row - 3

    if side_col and not side_too_large and #side_lines <= side_max_height then
      width = narrow_width
      col = side_col
      row = math.max(1, pum.row)
      lines = side_lines
      height = #side_lines
    else
      overlay = true
    end
  else
    overlay = true
  end

  if overlay then
    -- Hide the menu for the modal overlay and restore it when the docs close.
    local hid_pum = hide_pum()
    docs_overlay = true

    width = math.min(math.max(max_width + 2, 64), math.min(100, vim.o.columns - 8))
    lines = wrap_doc(raw, width)
    local max_height = math.max(8, math.floor(vim.o.lines * 0.7))
    height = math.min(math.max(#lines, 1), max_height)
    row = math.max(1, math.floor((vim.o.lines - height - 2) / 2))
    col = math.max(0, math.floor((vim.o.columns - width - 2) / 2))

    -- If the menu could not be hidden, it is drawn above every floating
    -- window, so shift the overlay into the free area above or below it.
    if not hid_pum and pum and pum.width and pum.width > 0 then
      local pum_top = pum.row
      local pum_bottom = pum.row + pum.height - 1
      local doc_bottom = row + height - 1
      local rows_overlap = doc_bottom >= pum_top and row <= pum_bottom
      local cols_overlap = col + width - 1 >= pum.col
        and col <= pum.col + pum.width - 1
      if rows_overlap and cols_overlap then
        local below_top = pum_bottom + 1
        local below_space = vim.o.lines - below_top - 2
        local above_space = pum_top - 2
        if below_space >= height then
          row = below_top + math.floor((below_space - height) / 2)
        elseif above_space >= height then
          row = math.max(1, pum_top - height - 1 - math.floor((above_space - height) / 2))
        elseif below_space >= above_space then
          height = math.max(1, below_space)
          row = below_top
        else
          height = math.max(1, above_space)
          row = math.max(1, pum_top - height - 1)
        end
      end
    end
    open_scrim()
  end

  if not docs_buf or not vim.api.nvim_buf_is_valid(docs_buf) then
    docs_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[docs_buf].buftype = 'nofile'
    vim.bo[docs_buf].bufhidden = 'hide'
    vim.bo[docs_buf].swapfile = false
    vim.bo[docs_buf].filetype = 'markdown'
  end
  vim.bo[docs_buf].modifiable = true
  vim.api.nvim_buf_set_lines(docs_buf, 0, -1, false, lines)
  vim.bo[docs_buf].modifiable = false

  docs_generation = docs_generation + 1
  docs_win = vim.api.nvim_open_win(
    docs_buf,
    false,
    {
      relative = 'editor',
      row = row,
      col = col,
      width = width,
      height = height,
      style = 'minimal',
      border = 'rounded',
      title = ' Completion docs ',
      title_pos = 'center',
      focusable = false,
      noautocmd = true,
      zindex = 60
    }
  )
  vim.wo[docs_win].winhighlight = 'Normal:Pmenu,FloatBorder:PmenuBorder,EndOfBuffer:Pmenu'
  vim.wo[docs_win].winblend = 0
  -- Lines are wrapped in Lua, so let the window display them verbatim.
  vim.wo[docs_win].wrap = false
  vim.wo[docs_win].linebreak = false
  vim.wo[docs_win].cursorline = false
  vim.wo[docs_win].number = false
  vim.wo[docs_win].relativenumber = false
  vim.wo[docs_win].signcolumn = 'no'
  vim.wo[docs_win].foldcolumn = '0'

  if docs_overlay then
    set_overlay_keymaps()
  end
end

local function toggle_docs()
  if docs_visible() then
    local was_overlay = close_docs()
    if was_overlay then
      restore_pum()
    else
      cancel_pum()
    end
    return
  end
  show_docs()
end

-- <C-k> toggles the docs.  In the modal overlay the menu is hidden; the
-- buffer-local keys installed by set_overlay_keymaps() put it back and then
-- replay Enter/arrows, so the same item can be accepted or navigated.
vim.keymap.set(
  'i',
  '<C-k>',
  toggle_docs,
  {
    desc = 'Completion: full documentation'
  }
)

vim.api.nvim_create_autocmd(
  'CompleteChanged',
  {
    group = group,
    callback = schedule_close
  }
)

vim.api.nvim_create_autocmd(
  'CompleteDone',
  {
    group = group,
    callback = function()
      -- <C-e> only hides the menu to show the docs overlay.
      if hiding_pum then
        hiding_pum = false
        return
      end
      schedule_close()
    end
  }
)

vim.api.nvim_create_autocmd(
  {
    'InsertLeave',
    'BufLeave'
  },
  {
    group = group,
    callback = function()
      cancel_pum()
      schedule_close()
    end
  }
)

vim.api.nvim_create_autocmd(
  'TextChangedI',
  {
    group = group,
    callback = function()
      if not docs_overlay then
        return
      end
      -- <C-e> briefly reports a text change while cancelling completion even
      -- though the line is untouched; do not close the overlay for that.
      if pending_pum and vim.api.nvim_get_current_line() == pending_pum.line then
        return
      end
      cancel_pum()
      vim.schedule(close_docs)
    end
  }
)

vim.api.nvim_create_autocmd(
  'VimLeavePre',
  {
    group = group,
    callback = function()
      cancel_pum()
      close_docs()
    end
  }
)

return M
