return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- trouble.nvim
  hi({
    TroubleNormal       = { fg = p.base1, bg = p.base7 },
    TroubleNormalNC     = { fg = p.base1, bg = p.base7 },
    TroubleText         = { fg = p.base1 },
    TroubleCount        = { fg = p.purple_text, bg = p.purple_bg },
    TroubleFilename     = { fg = p.base1, bold = true },
    TroubleDirectory    = { fg = p.teal_text },
    TroubleCode         = { fg = p.base2 },
    TroubleLocation     = { fg = p.base2 },
    TroubleIndent       = { fg = p.base4 },
    TroubleIcon         = { fg = p.base2 },
    TroubleIconDirectory = { fg = p.teal_text },
    TroublePos          = { fg = p.base3 },
    TroubleSource       = { fg = p.base3 },
    TroublePreview      = { fg = p.base1, bg = p.base6 },
    TroubleStatusline   = { fg = p.base7, bg = p.base1, bold = true },
  })
end
