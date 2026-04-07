return {
  'echasnovski/mini.indentscope',
  lazy = false,
  priority = 995,
  config = function()
    require('mini.indentscope').setup({
      draw = {
        delay = 0,
        priority = 2,
        animation = require('mini.indentscope').gen_animation.linear({
          duration = 0,
          unit = 'total',
          easing = 'in-out'
        })
      },
      options = {
        border = 'top',
        try_as_border = false,
        indent_at_cursor = true
      },
      symbol = '│'
    })
  end
}
