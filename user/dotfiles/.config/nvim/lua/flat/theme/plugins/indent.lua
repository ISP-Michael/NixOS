return function(hi, p)
  hi({
    IblIndent = { fg = p.base5 },
    IblWhitespace = { fg = p.base5 },
    IblScope = { fg = p.base4 },

    -- Visual selection: the guide cell keeps the selection background, so the
    -- whole indent area stays light.  The glyph uses base2, not the much
    -- darker normal guide colour: it stays visible without becoming a black
    -- bar, keeping the same restrained contrast as the unselected guides.
    IblIndentSelected = {
      fg = p.base2,
      bg = p.base1,
      nocombine = true
    },
    IblWhitespaceSelected = {
      fg = p.base7,
      bg = p.base1,
      nocombine = true
    },
    IblScopeSelected = {
      fg = p.base2,
      bg = p.base1,
      nocombine = true
    },

    -- Empty lines have no text cells for Visual to paint, so the selection
    -- looked interrupted.  The plugin puts this background behind such lines.
    IndentGuideSelectedLine = {
      fg = p.base1,
      bg = p.base1
    },

    MiniIndentscopeSymbol = { fg = p.base4 },
    MiniIndentscopeSymbolOff = { fg = p.base5 },
    MiniIndentscopeSymbolWithStartScope = { fg = p.base3 },
  })
end
