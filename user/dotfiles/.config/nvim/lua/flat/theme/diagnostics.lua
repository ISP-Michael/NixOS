return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- ============================================================================
  -- Diagnostics (helix diagnostic.*, error/warning/info scopes)
  -- ============================================================================

  hi({
    DiagnosticError   = { fg = p.diff_delete },
    DiagnosticWarn    = { fg = p.orange_text },
    DiagnosticInfo    = { fg = p.orange_text }, -- flatwhite uses the same colour for info and warning
    DiagnosticHint    = { fg = p.base2 },
    DiagnosticOk      = { fg = p.diff_add },

    DiagnosticUnderlineError = {
      sp = p.diff_delete,
      undercurl = true
    },
    DiagnosticUnderlineWarn  = {
      sp = p.orange_text,
      undercurl = true
    },
    DiagnosticUnderlineInfo  = {
      sp = p.orange_text_sec,
      undercurl = true
    },
    DiagnosticUnderlineHint  = {
      sp = p.base2,
      undercurl = true
    },
    DiagnosticUnderlineOk    = {
      sp = p.diff_add,
      undercurl = true
    },

    DiagnosticVirtualTextError = { fg = p.diff_delete },
    DiagnosticVirtualTextWarn  = {
      fg = p.orange_text,
      bg = p.orange_bg
    },
    DiagnosticVirtualTextInfo  = {
      fg = p.orange_text,
      bg = p.orange_bg
    },
    DiagnosticVirtualTextHint  = { fg = p.base2 },
    DiagnosticVirtualTextOk    = { fg = p.diff_add },

    DiagnosticFloatingError = {
      fg = p.diff_delete,
      bg = p.base6
    },
    DiagnosticFloatingWarn  = {
      fg = p.orange_text,
      bg = p.base6
    },
    DiagnosticFloatingInfo  = {
      fg = p.orange_text,
      bg = p.base6
    },
    DiagnosticFloatingHint  = {
      fg = p.base2,
      bg = p.base6
    },
    DiagnosticFloatingOk    = {
      fg = p.diff_add,
      bg = p.base6
    },

    DiagnosticSignError = { fg = p.diff_delete },
    DiagnosticSignWarn  = { fg = p.orange_text },
    DiagnosticSignInfo  = { fg = p.orange_text },
    DiagnosticSignHint  = { fg = p.base2 },
    DiagnosticSignOk    = { fg = p.diff_add },

    DiagnosticDeprecated   = { strikethrough = true },
    DiagnosticUnnecessary  = { fg = p.base2 }, -- diagnostic.unnecessary: dim

    LspReferenceText  = { bg = p.base6 },
    LspReferenceRead  = { bg = p.base6 },
    LspReferenceWrite = { bg = p.base4 },
    LspSignatureActiveParameter = { bg = p.base4 },
    LspInlayHint = {
      fg = p.base3,
      italic = true
    }, -- ui.virtual.inlay-hint
    LspCodeLens = {
      fg = p.base3,
      italic = true
    },
    LspCodeLensSeparator = { fg = p.base4 },
  })
end
