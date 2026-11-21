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

vim.api.nvim_create_autocmd(
  'UIEnter',
  {
    once = true,
    callback = function()
      vim.schedule(
        function()
          P.use('indent-blankline.nvim')
          P.use('mini.indentscope')
        end
      )
    end,
  }
)

return {}
