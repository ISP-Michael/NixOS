return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- ============================================================================
  -- Tree-sitter captures
  -- ============================================================================

  hi({
    ['@variable']                 = { fg = p.base1 },
    -- bg = base7 because Neovim merges captures: without it the blue
    -- `variable.parameter` background of `self`/`cls` would leak through.
    ['@variable.builtin']         = { fg = p.base1, bg = p.base7 },
    ['@variable.parameter']       = blue,
    ['@variable.parameter.builtin'] = blue,
    ['@variable.member']          = { fg = p.base1 },

    ['@constant']                 = blue,
    ['@constant.builtin']         = blue,
    ['@constant.macro']           = blue,
    ['@constant.builtin.boolean'] = blue,

    ['@module']                   = teal,
    ['@module.builtin']           = teal,
    ['@namespace']                = teal,

    ['@label']                    = { fg = p.base1, bold = true },

    ['@string']                   = green,
    ['@string.documentation']     = green, -- docstrings are plain strings in helix
    ['@string.regexp']            = green,
    ['@string.special']           = green,
    ['@string.special.symbol']    = green,
    ['@string.special.path']      = green,
    ['@string.special.url']       = green,
    ['@string.escape']            = blue, -- helix constant.character.escape

    ['@character']                = blue,
    ['@character.special']        = blue,
    ['@boolean']                  = blue,
    ['@number']                   = blue,
    ['@number.float']             = blue,

    ['@type']                     = { fg = p.base1 },
    ['@type.builtin']             = { fg = p.base1 },
    ['@type.definition']          = { fg = p.base1 },

    ['@attribute']                = blue,
    ['@attribute.builtin']        = blue,
    ['@property']                 = { fg = p.base1 },

    ['@function']                 = { fg = p.base1, bold = true },
    ['@function.builtin']         = { fg = p.base1, bold = true },
    ['@function.call']            = { fg = p.base1, bold = true },
    ['@function.macro']           = { fg = p.base1, bold = true },
    ['@function.method']          = { fg = p.base1, bold = true },
    ['@function.method.call']     = { fg = p.base1, bold = true },
    ['@function.special']         = { fg = p.base1, bold = true },
    ['@constructor']              = { fg = p.base1 },
    ['@operator']                 = { fg = p.base1 },
    ['@operator.special']         = { fg = p.base1 },

    ['@keyword']                  = purple,
    ['@keyword.function']         = purple,
    ['@keyword.operator']         = purple,
    ['@keyword.import']           = purple,
    ['@keyword.type']             = purple,
    ['@keyword.modifier']         = purple,
    ['@keyword.repeat']           = purple,
    ['@keyword.return']           = purple,
    ['@keyword.debug']            = purple,
    ['@keyword.exception']        = purple,
    ['@keyword.conditional']      = purple,
    ['@keyword.conditional.ternary'] = purple,
    ['@keyword.coroutine']        = purple,
    ['@keyword.directive']        = purple,
    ['@keyword.directive.define'] = purple,
    ['@keyword.storage']          = purple,

    ['@punctuation']              = { fg = p.base1 },
    ['@punctuation.delimiter']    = { fg = p.base1 },
    ['@punctuation.bracket']      = { fg = p.base1, bold = true },
    ['@punctuation.special']      = { fg = p.base1 },

    ['@comment']                  = { fg = p.base3, italic = true },
    ['@comment.documentation']    = { fg = p.base2 },
    ['@comment.error']            = { fg = p.diff_delete },
    ['@comment.warning']          = { fg = p.orange_text },
    ['@comment.todo']             = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@comment.note']             = { fg = p.blue_text, bg = p.blue_bg },

    ['@tag']                      = { fg = p.base1 },
    ['@tag.builtin']              = { fg = p.base1 },
    ['@tag.attribute']            = blue, -- helix `attribute`
    ['@tag.delimiter']            = { fg = p.base1, bold = true },

    ['@special']                  = blue,

    ['@markup.heading']           = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@markup.heading.1']         = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@markup.heading.2']         = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@markup.heading.3']         = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@markup.heading.4']         = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@markup.heading.5']         = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@markup.heading.6']         = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@markup.heading.marker']    = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@markup.raw']               = orange,
    ['@markup.raw.inline']        = orange,
    ['@markup.raw.block']         = orange,
    ['@markup.strong']            = { bold = true },
    ['@markup.bold']              = { bold = true },
    ['@markup.italic']            = { italic = true },
    ['@markup.strikethrough']     = { strikethrough = true },
    ['@markup.link']              = blue,
    ['@markup.link.label']        = blue,
    ['@markup.link.text']         = blue,
    ['@markup.link.url']          = { fg = p.blue_text, bg = p.blue_bg, underline = true },
    ['@markup.quote']             = teal,
    ['@markup.list']              = purple,
    ['@markup.list.numbered']     = purple,
    ['@markup.list.unnumbered']   = purple,
    ['@markup.list.checked']      = purple,
    ['@markup.list.unchecked']    = purple,
    ['@markup.math']              = { fg = p.base1 },
    ['@markup.environment']       = { fg = p.teal_text },
    ['@markup.environment.name']  = { fg = p.teal_text_sec },

    ['@diff.plus']                = { fg = p.diff_add },
    ['@diff.minus']               = { fg = p.diff_delete },
    ['@diff.delta']               = { fg = p.diff_change },

    ['@conceal']                  = { fg = p.base1 },

    -- Deprecated capture names still used by some queries/plugins
    ['@parameter']                = blue,
    ['@field']                    = { fg = p.base1 },
    ['@method']                   = { fg = p.base1, bold = true },
    ['@conditional']              = purple,
    ['@repeat']                   = purple,
    ['@exception']                = purple,
    ['@include']                  = purple,
    ['@define']                   = purple,
    ['@preproc']                  = purple,
    ['@storageclass']             = purple,
    ['@type.qualifier']           = purple,
    ['@structure']                = { fg = p.base1 },
    ['@typedef']                  = { fg = p.base1 },
    ['@debug']                    = purple,

    ['@text']                     = { fg = p.base1 },
    ['@text.literal']             = orange,
    ['@text.reference']           = blue,
    ['@text.title']               = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@text.uri']                 = { fg = p.blue_text, bg = p.blue_bg, underline = true },
    ['@text.underline']           = { underline = true },
    ['@text.todo']                = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    ['@text.note']                = { fg = p.blue_text, bg = p.blue_bg },
    ['@text.warning']             = { fg = p.orange_text, bg = p.orange_bg },
    ['@text.danger']              = { fg = p.diff_delete },
    ['@text.diff.add']            = { fg = p.diff_add },
    ['@text.diff.delete']         = { fg = p.diff_delete },
  })
end
