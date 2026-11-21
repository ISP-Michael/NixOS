return function(hi, p)
  hi({
    IblIndent = { fg = p.base5 },
    IblWhitespace = { fg = p.base5 },
    IblScope = { fg = p.base4 },

    MiniIndentscopeSymbol = { fg = p.base4 },
    MiniIndentscopeSymbolOff = { fg = p.base5 },
    MiniIndentscopeSymbolWithStartScope = { fg = p.base3 },
  })
end
