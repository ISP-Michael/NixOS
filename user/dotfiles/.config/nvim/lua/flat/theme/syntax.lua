return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- ============================================================================
  -- Legacy syntax groups (filetypes without a tree-sitter parser)
  -- ============================================================================

  hi({
    Comment        = { fg = p.base3, italic = true },
    String         = green,
    Character      = blue,
    Number         = blue,
    Boolean        = blue,
    Identifier     = { fg = p.base1 },
    Function       = { fg = p.base1, bold = true },
    Statement      = purple,
    Conditional    = purple,
    Repeat         = purple,
    Label          = { fg = p.base1, bold = true },
    Exception      = purple,
    Keyword        = purple,
    Operator       = { fg = p.base1 },
    Delimiter      = { fg = p.base1 },
    Special        = blue,
    SpecialChar    = blue,
    SpecialComment = { fg = p.base2, italic = true },
    Tag            = { fg = p.base1 },
    Type           = { fg = p.base1 },
    StorageClass   = purple,
    Structure      = purple,
    Typedef        = purple,
    PreProc        = purple,
    Include        = purple,
    PreCondit      = purple,
    Todo           = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    Error          = { fg = p.diff_delete },
    Debug          = { fg = p.orange_text },
    Underlined     = { underline = true },
    Ignore         = {},
  })

  -- These four groups are `numhl` targets in the diagnostic config.  Flatwhite
  -- renders the current line number as a dark reversed chip; a coloured number
  -- on top of it is unreadable.  Keep them empty, diagnostics still show up via
  -- signs, virtual text and undercurls.
  hi({
    Macro    = {},
    Float    = {},
    Constant = {},
    Define   = {},
  })
end
