return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- ============================================================================
  -- Editor UI (helix ui.* scopes)
  -- ============================================================================

  hi({
    Normal        = {
      fg = p.base1,
      bg = p.base7
    },
    NormalNC      = {
      fg = p.base1,
      bg = p.base7
    }, -- helix does not dim inactive windows
    NormalFloat   = {
      fg = p.base1,
      bg = p.base6
    }, -- ui.popup
    FloatNormal   = { link = 'NormalFloat' },
    FloatBorder   = {
      fg = p.base3,
      bg = p.base6
    },
    FloatTitle    = {
      fg = p.base1,
      bg = p.base6,
      bold = true
    },
    FloatFooter   = {
      fg = p.base2,
      bg = p.base6
    },

    -- ui.cursor / ui.cursor.primary: fg base1, bg base7, reversed
    Cursor        = {
      fg = p.cursor_fg,
      bg = p.cursor_bg
    },
    lCursor       = { link = 'Cursor' },
    CursorIM      = { link = 'Cursor' },
    TermCursor    = { link = 'Cursor' },

    CursorLine    = { bg = p.base6 }, -- ui.cursorline
    CursorColumn  = { bg = p.base6 },
    ColorColumn   = { bg = p.base6 }, -- ui.virtual.ruler

    LineNr        = {
      fg = p.base1,
      bg = p.base6
    }, -- ui.linenr
    LineNrAbove   = {
      fg = p.base1,
      bg = p.base6
    },
    LineNrBelow   = {
      fg = p.base1,
      bg = p.base6
    },
    CursorLineNr  = {
      fg = p.base6,
      bg = p.base1
    }, -- ui.linenr.selected, reversed
    SignColumn    = { bg = p.base6 },
    CursorLineSign = { bg = p.base6 },
    CursorLineFold = { bg = p.base6 },
    FoldColumn    = {
      fg = p.base2,
      bg = p.base6
    },
    Folded        = {
      fg = p.base2,
      bg = p.base6
    },

    EndOfBuffer   = { fg = p.base5 },
    NonText       = { fg = p.base4 },
    Whitespace    = { fg = p.base5 }, -- ui.virtual.whitespace
    SpecialKey    = { fg = p.base4 },
    Conceal       = {
      fg = p.base1,
      bg = p.base7
    },
    Directory     = { fg = p.teal_text },

    Title         = {
      fg = purple.fg,
      bg = purple.bg,
      bold = true
    }, -- markup.heading

    -- ui.selection.primary
    -- Выделение инвертирует цвета каждого токена: фоном становится его
    -- foreground, а текст — его background (как reverse в терминале).
    Visual        = { reverse = true },
    VisualNOS     = { link = 'Visual' },

    Search        = {
      fg = p.base6,
      bg = p.base2
    }, -- ui.selection.primary (solid)
    IncSearch     = {
      fg = p.base7,
      bg = p.base1
    },
    CurSearch     = {
      fg = p.base7,
      bg = p.base1,
      bold = true
    },
    Substitute    = {
      fg = p.base6,
      bg = p.base2
    },
    MatchParen    = {
      fg = p.matchparen_fg,
      bg = p.matchparen_bg,
      bold = true
    }, -- ui.cursor.match, reversed
    QuickFixLine  = { bg = p.base4 },

    -- ui.menu / ui.menu.selected (reversed)
    Pmenu         = {
      fg = p.base1,
      bg = p.base5
    },
    PmenuSel      = {
      fg = p.base6,
      bg = p.base1
    },
    PmenuKind     = {
      fg = p.base2,
      bg = p.base5
    },
    PmenuKindSel  = {
      fg = p.base4,
      bg = p.base1
    },
    PmenuExtra    = {
      fg = p.base2,
      bg = p.base5,
      italic = true
    },
    PmenuExtraSel = {
      fg = p.base4,
      bg = p.base1,
      italic = true
    },
    PmenuMatch    = {
      fg = p.purple_text,
      bg = p.base5,
      bold = true
    },
    PmenuMatchSel = {
      fg = p.purple_bg,
      bg = p.base1,
      bold = true
    },
    PmenuSbar     = { bg = p.base4 },
    PmenuThumb    = { bg = p.base3 },
    PmenuBorder   = {
      fg = p.base1,
      bg = p.base5
    },
    PmenuShadow   = { bg = p.base4 },
    WildMenu      = { link = 'PmenuSel' },

    MsgArea       = {
      fg = p.base1,
      bg = p.base7
    },
    MsgSeparator  = {
      fg = p.base4,
      bg = p.base6
    },

    -- ui.statusline / ui.statusline.inactive
    StatusLine     = {
      fg = p.sl_fg,
      bg = p.sl_bg,
      bold = true
    },
    StatusLineNC   = {
      fg = p.sl_nc_fg,
      bg = p.sl_nc_bg
    },
    StatusLineTerm = { link = 'StatusLine' },
    StatusLineTermNC = { link = 'StatusLineNC' },
    WinBar         = {
      fg = p.base1,
      bg = p.base6,
      bold = true
    },
    WinBarNC       = {
      fg = p.base2,
      bg = p.base6
    },

    WinSeparator  = {
      fg = p.base4,
      bg = p.base7
    },
    VertSplit     = { link = 'WinSeparator' },

    TabLine       = {
      fg = p.base1,
      bg = p.base6
    },
    TabLineSel    = {
      fg = p.base7,
      bg = p.base1,
      bold = true
    },
    TabLineFill   = { bg = p.base6 },

    ErrorMsg      = {
      fg = p.diff_delete,
      bold = true
    },
    WarningMsg    = { fg = p.orange_text },
    MoreMsg       = { fg = p.orange_text },
    Question      = { fg = p.teal_text },
    ModeMsg       = {
      fg = p.base1,
      bold = true
    },

    SpellBad      = {
      sp = p.diff_delete,
      undercurl = true
    },
    SpellCap      = {
      sp = p.orange_text,
      undercurl = true
    },
    SpellRare     = {
      sp = p.blue_text_sec,
      undercurl = true
    },
    SpellLocal    = {
      sp = p.teal_text_sec,
      undercurl = true
    },

    -- diff.plus / diff.delta / diff.minus
    DiffAdd       = { bg = p.green_bg },
    DiffChange    = { bg = p.orange_bg },
    DiffDelete    = {
      fg = p.diff_delete,
      bg = p.base4
    },
    DiffText      = {
      fg = p.base6,
      bg = p.base2
    },
    diffAdded     = { fg = p.diff_add },
    diffRemoved   = { fg = p.diff_delete },
    diffChanged   = { fg = p.diff_change },
    diffNewFile   = { fg = p.diff_add },
    diffOldFile   = { fg = p.diff_delete },
    diffFile      = { fg = p.blue_text },
    diffLine      = { fg = p.base2 },
    diffIndexLine = { fg = p.base3 },

    Terminal      = {
      fg = p.base1,
      bg = p.base7
    },
  })
end
