-- Заливка пустых строк внутри многострочных строк.
--
-- Nvim не продлевает фон @string на пустую строку: там просто нет символов.
-- Декоратор рисует на пустой строке виртуальные пробелы с фоном @string,
-- длина = минимум из двух ближайших непустых строк. Строка в буфере остаётся
-- пустой, меняется только отрисовка.
local M = {}

local ns = vim.api.nvim_create_namespace('flat_string_fill')
local installed = false

-- Корневые узлы многострочных строк для языков, где это встречается.
local string_types = {
  block_scalar = true,
  heredoc_block = true,
  heredoc_body = true,
  indented_string_expression = true,
  raw_string_literal = true,
  string = true,
  string_expression = true,
  string_literal = true,
  template_string = true,
}

local function is_flat()
  local name = vim.g.colors_name
  return name == 'flatwhite' or name == 'flatblack'
end

local function get_line(buf, row)
  return vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ''
end

local function is_blank(buf, row)
  return get_line(buf, row):match('^%s*$') ~= nil
end

---@return integer|nil start_row
---@return integer|nil end_row
local function string_range(buf, row)
  local ok, node = pcall(
    vim.treesitter.get_node,
    {
      bufnr = buf,
      pos = {
        row,
        0
      }
    }
  )
  if not ok or not node then
    return nil
  end

  while node do
    if string_types[node:type()] then
      local start_row, _, end_row, _ = node:range()
      if start_row < row and row < end_row then
        return start_row, end_row
      end
      return nil
    end
    node = node:parent()
  end
end

local function fill(buf, lnum)
  local row = lnum - 1
  local start_row, end_row = string_range(buf, row)
  if not start_row then
    return
  end

  local prev = row - 1
  while prev >= start_row and is_blank(buf, prev) do
    prev = prev - 1
  end

  local next = row + 1
  while next <= end_row and is_blank(buf, next) do
    next = next + 1
  end

  if prev < start_row or next > end_row then
    return
  end

  local prev_line = get_line(buf, prev)
  local next_line = get_line(buf, next)
  local width = math.min(
    vim.fn.strdisplaywidth(prev_line),
    vim.fn.strdisplaywidth(next_line)
  )
  if width <= 0 then
    return
  end

  vim.api.nvim_buf_set_extmark(
    buf,
    ns,
    row,
    0,
    {
      ephemeral = true,
      priority = 100,
      virt_text = {
        {
          string.rep(' ', width),
          '@string'
        }
      },
      virt_text_pos = 'overlay',
    }
  )
end

function M.attach()
  if installed then
    return
  end
  installed = true

  vim.api.nvim_set_decoration_provider(
    ns,
    {
      on_win = function(_, _, buf, topline, botline)
        if not is_flat() then
          return false
        end

        local count = vim.api.nvim_buf_line_count(buf)
        local first = math.max(1, topline)
        local last = math.min(botline, count)
        for lnum = first, last do
          if is_blank(buf, lnum - 1) then
            pcall(fill, buf, lnum)
          end
        end
        return false
      end,
    }
  )
end

return M
