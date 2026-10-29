-- Курсор для flatwhite / flatblack.
--
-- У Neovim группа Cursor статическая, поэтому блок всегда одного цвета (в
-- flatwhite это тёмный квадрат). Здесь Cursor пересчитывается на каждом
-- перемещении: фоном становится цвет токена под курсором, а текстом — фон
-- этого токена. В терминале с `cursor none` (kitty) то же самое делает сама
-- терминалка, а в Neovide/других GUI цвет берётся из этой группы.
local M = {}

local augroup_name = 'flat_cursor'
local cache = {}
local last

local function get_hl(name)
  local hl = cache[name]
  if hl == nil then
    local ok, result = pcall(vim.api.nvim_get_hl, 0, { name = name })
    hl = (ok and result) or {}
    cache[name] = hl
  end
  return hl
end

local function merge(hl, fg, bg)
  if not hl then
    return fg, bg
  end
  return hl.fg or fg, hl.bg or bg
end

local function hex(n)
  if type(n) ~= 'number' then
    return nil
  end
  return string.format('#%06x', n)
end

--- Цвета токена в позиции курсора.
---@return integer|nil fg
---@return integer|nil bg
local function token_at_cursor()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  local pos = vim.api.nvim_win_get_cursor(win)
  local row, col = pos[1] - 1, pos[2]
  local fg, bg

  local ok, captures = pcall(vim.treesitter.get_captures_at_pos, buf, row, col)
  if ok and captures then
    for _, capture in ipairs(captures) do
      fg, bg = merge(get_hl('@' .. capture.capture), fg, bg)
    end
  end

  -- Семантические токены LSP рисуются поверх treesitter.
  local sem_ok, tokens = pcall(vim.lsp.semantic_tokens.get_at_pos, buf, row, col)
  if sem_ok and tokens then
    for _, token in ipairs(tokens) do
      fg, bg = merge(get_hl('@lsp.type.' .. token.type), fg, bg)
      for modifier in pairs(token.modifiers or {}) do
        fg, bg = merge(get_hl('@lsp.mod.' .. modifier), fg, bg)
      end
    end
  end

  -- Запасной вариант для файлов без treesitter-парсера.
  if not fg and not bg then
    local syn_ok, id = pcall(vim.fn.synID, row + 1, col + 1, true)
    if syn_ok and id ~= 0 then
      local function attr(what)
        local color = vim.fn.synIDattr(id, what, 'gui')
        if color and color ~= '' and color:sub(1, 1) == '#' then
          return tonumber(color:sub(2), 16)
        end
      end
      fg, bg = attr('fg#'), attr('bg#')
    end
  end

  local normal = get_hl('Normal')
  fg = fg or normal.fg
  bg = bg or normal.bg
  if not fg or not bg or fg == bg then
    return nil, nil
  end
  return fg, bg
end

local function update()
  if vim.g.colors_name ~= 'flatwhite' and vim.g.colors_name ~= 'flatblack' then
    pcall(vim.api.nvim_del_augroup_by_name, augroup_name)
    cache = {}
    last = nil
    return
  end

  local fg, bg = token_at_cursor()
  if not fg or not bg then
    return
  end
  local cursor_fg, cursor_bg = hex(bg), hex(fg)
  local key = cursor_fg .. cursor_bg
  if key == last then
    return
  end
  last = key
  vim.api.nvim_set_hl(0, 'Cursor', { fg = cursor_fg, bg = cursor_bg })
  vim.api.nvim_set_hl(0, 'TermCursor', { fg = cursor_fg, bg = cursor_bg })
end

function M.attach()
  local group = vim.api.nvim_create_augroup(augroup_name, { clear = true })
  vim.api.nvim_create_autocmd(
    { 'CursorMoved', 'CursorMovedI', 'BufEnter', 'WinEnter', 'ModeChanged', 'ColorScheme' },
    {
      group = group,
      callback = update,
    }
  )
  cache = {}
  last = nil
  update()
end

return M
