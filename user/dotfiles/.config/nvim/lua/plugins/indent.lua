-- Vertical indent guides. ibl draws the static lines at every indent level,
-- mini.indentscope highlights the block the cursor is currently in. Both are
-- visible in every buffer and cheap, so they load once after the UI appears.
local P = require('pack')

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

-- The theme selects with `Visual = { reverse = true }`, so every cell swaps
-- its own foreground and background. Indent guides have their own foreground
-- and cannot inherit that per-token background; with `nocombine` they ignore
-- Visual completely and leave dark gaps inside the selection. Hide both guide
-- layers while a visual/select mode is active, then redraw them on exit.
local in_visual = false

local function set_guides(enabled)
  if P.loaded['indent-blankline.nvim'] then
    require('ibl').update(
      {
        enabled = enabled
      }
    )
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

local function is_visual_mode()
  return vim.fn.mode(1):match('^[vV\22sS\19]') ~= nil
end

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
