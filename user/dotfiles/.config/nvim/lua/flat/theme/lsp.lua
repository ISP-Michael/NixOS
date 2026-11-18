return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- ============================================================================
  -- LSP semantic tokens
  -- ============================================================================
  --
  -- Helix 25.07 has no LSP semantic highlighting at all: it colours tokens from
  -- tree-sitter only.  Neovim enables semantic tokens by default, and they are
  -- coarser than the tree-sitter scopes (a `@constant` becomes just `variable`),
  -- so every standard `@lsp.type.*` group is cleared and the tree-sitter colours
  -- stay in charge.  The exceptions are the tokens tree-sitter cannot know
  -- about, which are exactly the things Helix gets from its locals queries:
  -- references to parameters are blue, functions stay bold, deprecated things
  -- are crossed out.

  hi({
    ['@lsp.type.class']         = {},
    ['@lsp.type.comment']       = {},
    ['@lsp.type.decorator']     = {},
    ['@lsp.type.enum']          = {},
    ['@lsp.type.enumMember']    = {},
    ['@lsp.type.event']         = {},
    ['@lsp.type.interface']     = {},
    ['@lsp.type.keyword']       = {},
    ['@lsp.type.macro']         = { bold = true },
    ['@lsp.type.modifier']      = {},
    ['@lsp.type.namespace']     = {},
    ['@lsp.type.number']        = {},
    ['@lsp.type.operator']      = {},
    ['@lsp.type.parameter']     = blue,
    ['@lsp.type.property']      = {},
    ['@lsp.type.regexp']        = {},
    ['@lsp.type.string']        = {},
    ['@lsp.type.struct']        = {},
    ['@lsp.type.type']          = {},
    ['@lsp.type.typeParameter'] = {},
    ['@lsp.type.variable']      = {},

    ['@lsp.type.function']      = { bold = true },
    ['@lsp.type.method']        = { bold = true },

    ['@lsp.mod.deprecated']     = { strikethrough = true },
    ['@lsp.mod.readonly']       = {},
  })
end
