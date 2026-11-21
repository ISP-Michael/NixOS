return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- gitsigns (helix diff.plus/delta/minus signs)
  hi({
    GitSignsAdd        = { fg = p.diff_add },
    GitSignsChange     = { fg = p.diff_change },
    GitSignsDelete     = { fg = p.diff_delete },
    GitSignsTopdelete  = { fg = p.diff_delete },
    GitSignsChangedelete = { fg = p.diff_change },
    GitSignsUntracked  = { fg = p.green_text_sec },
    GitSignsAddNr      = { fg = p.diff_add },
    GitSignsChangeNr   = { fg = p.diff_change },
    GitSignsDeleteNr   = { fg = p.diff_delete },
    GitSignsTopdeleteNr = { fg = p.diff_delete },
    GitSignsChangedeleteNr = { fg = p.diff_change },
    GitSignsUntrackedNr = { fg = p.green_text_sec },
    GitSignsAddLn      = { bg = p.green_bg },
    GitSignsChangeLn   = { bg = p.orange_bg },
    GitSignsDeleteLn   = { bg = p.base4 },
    GitSignsCurrentLineBlame = {
      fg = p.base3,
      italic = true
    },
  })
end
