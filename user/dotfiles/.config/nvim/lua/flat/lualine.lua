-- Общая тема lualine для flatwhite / flatblack.
local M = {}

function M.build(p)
  local bar = { fg = p.base1, bg = p.bar_bg }
  local inactive = { fg = p.bar_inactive_fg, bg = p.bar_inactive_bg }

  return {
    normal = {
      a = { fg = p.base7, bg = p.base1, gui = 'bold' },
      b = bar,
      c = bar,
    },
    insert = {
      a = { fg = p.purple_text, bg = p.purple_bg, gui = 'bold' },
      b = bar,
      c = bar,
    },
    visual = {
      a = { fg = p.base6, bg = p.base2, gui = 'bold' },
      b = bar,
      c = bar,
    },
    replace = {
      a = { fg = p.orange_text, bg = p.orange_bg, gui = 'bold' },
      b = bar,
      c = bar,
    },
    command = {
      a = { fg = p.teal_text, bg = p.teal_bg, gui = 'bold' },
      b = bar,
      c = bar,
    },
    terminal = {
      a = { fg = p.base7, bg = p.base1, gui = 'bold' },
      b = bar,
      c = bar,
    },
    inactive = {
      a = { fg = inactive.fg, bg = inactive.bg, gui = 'bold' },
      b = inactive,
      c = inactive,
    },
  }
end

return M
