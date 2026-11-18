return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- fzf-lua
  hi({
    FzfLuaNormal            = { fg = p.base1, bg = p.base7 },
    FzfLuaBorder            = { fg = p.base3, bg = p.base7 },
    FzfLuaTitle             = { fg = p.base1, bg = p.base7, bold = true },
    FzfLuaTitleFlags        = { fg = p.purple_text },
    FzfLuaBackdrop          = { bg = p.base6 },
    FzfLuaCursor            = { fg = p.base7, bg = p.base1 },
    FzfLuaCursorLine        = { bg = p.base6 },
    FzfLuaCursorLineNr      = { fg = p.base2, bg = p.base6 },
    FzfLuaSearch            = { fg = p.base6, bg = p.base2 },
    FzfLuaScrollBorderEmpty = { fg = p.base4, bg = p.base7 },
    FzfLuaScrollBorderFull  = { fg = p.base2, bg = p.base7 },
    FzfLuaScrollFloatEmpty  = { fg = p.base4, bg = p.base6 },
    FzfLuaScrollFloatFull   = { fg = p.base2, bg = p.base6 },
    FzfLuaHeaderText        = { fg = p.orange_text },
    FzfLuaHeaderBind        = { fg = p.purple_text },
    FzfLuaBufName           = { fg = p.teal_text },
    FzfLuaBufNr             = { fg = p.base2 },
    FzfLuaBufLineNr         = { fg = p.base3 },
    FzfLuaBufFlagCur        = { fg = p.diff_change },
    FzfLuaBufFlagAlt        = { fg = p.blue_text },
    FzfLuaDirPart           = { fg = p.base2 },
    FzfLuaFilePart          = { fg = p.base1 },
    FzfLuaLiveSym           = { fg = p.teal_text_sec },
    FzfLuaPreviewNormal     = { fg = p.base1, bg = p.base6 },
    FzfLuaPreviewBorder     = { fg = p.base3, bg = p.base6 },
    FzfLuaPreviewTitle      = { fg = p.base1, bg = p.base6, bold = true },
    FzfLuaFzfNormal         = { fg = p.base1, bg = p.base7 },
    FzfLuaFzfCursorLine     = { bg = p.base6 },
    FzfLuaFzfMatch          = { fg = p.purple_text, bg = p.purple_bg },
    FzfLuaFzfBorder         = { fg = p.base3, bg = p.base7 },
    FzfLuaFzfHeader         = { fg = p.orange_text },
    FzfLuaFzfInfo           = { fg = p.base3 },
    FzfLuaFzfPrompt         = { fg = p.base2 },
    FzfLuaFzfQuery          = { fg = p.base1 },
    FzfLuaFzfPointer        = { fg = p.diff_change },
    FzfLuaFzfMarker         = { fg = p.purple_text },
    FzfLuaFzfSpinner        = { fg = p.teal_text_sec },
    FzfLuaFzfScrollbar      = { fg = p.base3, bg = p.base6 },
    FzfLuaFzfSeparator      = { fg = p.base3, bg = p.base6 },
    FzfLuaFzfGutter         = { bg = p.base6 },
  })
end
