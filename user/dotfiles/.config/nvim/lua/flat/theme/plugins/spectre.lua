return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- spectre
  hi({
    SpectreBody       = { fg = p.base1, bg = p.base6 },
    SpectreBorder     = { fg = p.base3, bg = p.base6 },
    SpectreFile       = { fg = p.teal_text },
    SpectreDir        = { fg = p.base2 },
    SpectreSearch     = { fg = p.base6, bg = p.base2 },
    SpectreReplace    = { fg = p.purple_text, bg = p.purple_bg },
    SpectrePath       = { fg = p.base2 },
    SpectreHeader     = { fg = p.base2 },
    SpectreQuery      = { fg = p.base1, bold = true },
    SpectreConfig     = { fg = p.base2 },
    SpectrePanelWrite = { fg = p.diff_change },
    SpectreState      = { fg = p.base3 },
    SpectreStateOpened = { fg = p.orange_text },
  })
end
