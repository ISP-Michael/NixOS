-- Vertical indent guides. ibl draws the static lines at every indent level,
-- mini.indentscope highlights the block the cursor is currently in. Both are
-- visible in every buffer and cheap, so they load once after the UI appears.
local P = require('pack')

-- Experiment (21.11.2026): keep both guide layers visible in visual/select
-- mode. ibl uses guide_selected on the selection background, so the indent
-- area stays light without black bars; mini.indentscope is hidden there
-- because its line would cover the selected ibl guide at the same column.
-- `:IndentGuidesSelection hide` returns to the previous behaviour: both
-- layers are removed for the duration of the selection.
vim.g.indent_guides_selection = vim.g.indent_guides_selection or 'invert'

local function selection_mode()
  if vim.g.indent_guides_selection == 'hide' then
    return 'hide'
  end
  return 'invert'
end

local function is_visual_mode()
  return vim.fn.mode(1):match('^[vV\22sS\19]') ~= nil
end

local span_cache = {
  key = nil,
  rows = nil,
}

--- Screen-column spans of the current visual selection, keyed by row.
---@param bufnr number
---@return table<number, { start_col: number, end_col: number }>|nil
local function visual_spans(bufnr)
  if not is_visual_mode() or vim.api.nvim_get_current_buf() ~= bufnr then
    return nil
  end

  local mode = vim.fn.mode(1)
  local vpos = vim.fn.getpos('v')
  local cpos = vim.fn.getpos('.')
  local key = table.concat(
    {
      bufnr,
      mode,
      vpos[2],
      vpos[3],
      cpos[2],
      cpos[3],
      vim.api.nvim_buf_get_changedtick(bufnr)
    },
    ':'
  )
  if span_cache.key == key then
    return span_cache.rows
  end

  local rows = {}
  local visual_mode = vim.fn.visualmode()
  local linewise = mode == 'V' or mode == 'S'
  local region_type = visual_mode
  if region_type == '' then
    if mode == '\22' or mode == '\19' then
      region_type = '\22'
    else
      region_type = 'v'
    end
  end

  if linewise then
    local first = math.min(
      vpos[2],
      cpos[2]
    ) - 1
    local last = math.max(
      vpos[2],
      cpos[2]
    ) - 1
    for row = first, last do
      rows[row] = {
        start_col = 0,
        end_col = math.huge
      }
    end
  else
    local ok, region = pcall(
      vim.fn.getregionpos,
      vpos,
      cpos,
      {
        type = region_type,
        exclusive = false,
        eol = false
      }
    )
    if not ok then
      return nil
    end

    for _, segment in ipairs(region) do
      local start_pos = segment[1]
      local end_pos = segment[2]
      local row = start_pos[2] - 1
      local start_byte = start_pos[3]
      local end_byte = end_pos[3]
      if row >= 0 and start_byte > 0 and end_byte > 0 then
        local line = vim.api.nvim_buf_get_lines(
          bufnr,
          row,
          row + 1,
          false
        )[1] or ''
        local function screen_col(col)
          col = math.min(
            col,
            #line + 1
          )
          return vim.fn.virtcol(
            {
              row + 1,
              col
            }
          ) - 1
        end
        local start_col = screen_col(start_byte)
        local end_col = screen_col(end_byte)
        if end_col > start_col then
          rows[row] = {
            start_col = start_col,
            end_col = end_col
          }
        end
      end
    end

    -- getregionpos skips empty lines.  They are still selected, and the
    -- selection must not get a dark gap there.
    local first = math.min(
      vpos[2],
      cpos[2]
    ) - 1
    local last = math.max(
      vpos[2],
      cpos[2]
    ) - 1
    for row = first, last do
      if not rows[row] then
        rows[row] = {
          start_col = 0,
          end_col = math.huge
        }
      end
    end
  end

  span_cache.key = key
  span_cache.rows = rows
  return rows
end

---@param bufnr number
---@param row number
---@param virt_text table
---@return table
local function invert_virtual_text(_, bufnr, row, virt_text)
  local spans = visual_spans(bufnr)
  local span = spans and spans[row]
  if not span then
    return virt_text
  end

  local line = vim.api.nvim_buf_get_lines(
    bufnr,
    row,
    row + 1,
    false
  )[1]
  if line and line:match('^%s*$') then
    -- Let Visual draw its normal single selected cell on blank lines instead
    -- of covering it with an indent guide.
    return {}
  end

  local vcol = 0
  for _, chunk in ipairs(virt_text) do
    local width = vim.fn.strdisplaywidth(chunk[1])
    local next_vcol = vcol + width
    if next_vcol > span.start_col and vcol < span.end_col then
      local hl = chunk[2]
      if type(hl) == 'string' then
        hl = { hl }
      end
      local indent = false
      local scope = false
      for _, name in ipairs(hl) do
        if type(name) == 'string' and name:match('^@ibl%.indent%.char') then
          indent = true
        elseif type(name) == 'string' and name:match('^@ibl%.scope%.char') then
          scope = true
        end
      end
      if indent then
        chunk[2] = 'IblIndentSelected'
      elseif scope then
        chunk[2] = 'IblScopeSelected'
      else
        chunk[2] = 'IblWhitespaceSelected'
      end
    end
    vcol = next_vcol
  end
  return virt_text
end

local function setup_ibl()
  P.load('indent-blankline.nvim')
  require('ibl').setup(
    {
      indent = {
        char = '│'
      },
      scope = {
        enabled = false
      }
    }
  )
  local hooks = require('ibl.hooks')
  hooks.register(
    hooks.type.VIRTUAL_TEXT,
    invert_virtual_text
  )
end

local function setup_indentscope()
  P.load('mini.indentscope')
  require('mini.indentscope').setup(
    {
      draw = {
        delay = 0,
        priority = 2,
        animation = require('mini.indentscope').gen_animation.linear(
          {
            duration = 0,
            unit = 'total',
            easing = 'in-out'
          }
        )
      },
      options = {
        border = 'top',
        try_as_border = false,
        indent_at_cursor = true
      },
      symbol = '│'
    }
  )
end

P.register(
  'indent-blankline.nvim',
  setup_ibl
)

P.register(
  'mini.indentscope',
  setup_indentscope
)

local function set_guides(enabled)
  span_cache.key = nil

  if P.loaded['indent-blankline.nvim'] then
    local ibl = require('ibl')
    if selection_mode() == 'hide' then
      ibl.update(
        {
          enabled = enabled
        }
      )
    else
      ibl.update(
        {
          enabled = true
        }
      )
      ibl.refresh(vim.api.nvim_get_current_buf())
    end
  end

  if P.loaded['mini.indentscope'] then
    local scope = require('mini.indentscope')
    vim.g.miniindentscope_disable = not enabled
    if enabled then
      scope.draw()
    else
      scope.undraw()
    end
  end
end

local function set_selection_mode(mode)
  if mode == 'toggle' then
    mode = selection_mode() == 'hide' and 'invert' or 'hide'
  end
  if mode ~= 'invert' and mode ~= 'hide' then
    vim.notify(
      'IndentGuidesSelection: use invert, hide or toggle',
      vim.log.levels.WARN
    )
    return
  end

  vim.g.indent_guides_selection = mode
  set_guides(not is_visual_mode())
  vim.notify(
    'indent guides in visual selection: ' .. mode
  )
end

vim.api.nvim_create_user_command(
  'IndentGuidesSelection',
  function(opts)
    set_selection_mode(
      opts.args ~= '' and opts.args or 'toggle'
    )
  end,
  {
    nargs = '?',
    complete = function()
      return {
        'invert',
        'hide',
        'toggle'
      }
    end,
    desc = 'Indent guides in visual selection: invert, hide or toggle'
  }
)

vim.keymap.set(
  {
    'n',
    'x'
  },
  '<leader>ti',
  function()
    set_selection_mode('toggle')
  end,
  {
    desc = 'Toggle indent guides in visual selection'
  }
)

local in_visual = false

vim.api.nvim_create_autocmd(
  'ModeChanged',
  {
    callback = function()
      local visual = is_visual_mode()
      if visual == in_visual then
        return
      end
      in_visual = visual
      set_guides(not visual)
    end,
  }
)

vim.api.nvim_create_autocmd(
  'UIEnter',
  {
    once = true,
    callback = function()
      vim.schedule(
        function()
          P.use('indent-blankline.nvim')
          P.use('mini.indentscope')
          if is_visual_mode() then
            set_guides(false)
          end
        end
      )
    end,
  }
)

return {}
