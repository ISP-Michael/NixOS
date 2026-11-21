return function(hi, p)
  hi({
    IblIndent = { fg = p.base5 },
    IblWhitespace = { fg = p.base5 },
    IblScope = { fg = p.base4 },

    -- Visual selection: the guide cell keeps the selection background, so the
    -- whole indent area stays light.  Only the glyph itself uses the normal
    -- guide colour; swapping fg/bg made a dark block instead of a line.
    IblIndentSelected = {
      fg = p.base5,
      bg = p.base1,
      nocombine = true
    },
    IblWhitespaceSelected = {
      fg = p.base7,
      bg = p.base1,
      nocombine = true
    },
    IblScopeSelected = {
      fg = p.base4,
      bg = p.base1,
      nocombine = true
    },

    MiniIndentscopeSymbol = { fg = p.base4 },
    MiniIndentscopeSymbolOff = { fg = p.base5 },
    MiniIndentscopeSymbolWithStartScope = { fg = p.base3 },
  })
end
