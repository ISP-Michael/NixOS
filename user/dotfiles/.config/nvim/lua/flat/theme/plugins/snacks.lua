return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- snacks.nvim notifier
  hi({
    SnacksNotifier            = {
      fg = p.base1,
      bg = p.base6
    },
    SnacksNotifierMinimal     = {
      fg = p.base1,
      bg = p.base6
    },
    SnacksNotifierBorder      = {
      fg = p.base3,
      bg = p.base6
    },
    SnacksNotifierTitle       = {
      fg = p.base1,
      bold = true
    },
    SnacksNotifierIcon        = { fg = p.base2 },
    SnacksNotifierFooter      = { fg = p.base2 },
    SnacksNotifierHistory     = {
      fg = p.base1,
      bg = p.base6
    },
    SnacksNotifierHistoryTitle = {
      fg = p.base1,
      bold = true
    },
    SnacksNotifierHistoryDateTime = { fg = p.base2 },
  })

  for level, color in pairs({
    Error = p.diff_delete,
    Warn = p.orange_text,
    Info = p.blue_text,
    Debug = p.base2,
    Trace = p.base3,
  }) do
    hi({
      ['SnacksNotifier' .. level] = { fg = color },
      ['SnacksNotifierTitle' .. level] = {
        fg = color,
        bold = true
      },
      ['SnacksNotifierIcon' .. level] = { fg = color },
      ['SnacksNotifierBorder' .. level] = {
        fg = p.base3,
        bg = p.base6
      },
      ['SnacksNotifierFooter' .. level] = { fg = color },
    })
  end
end
