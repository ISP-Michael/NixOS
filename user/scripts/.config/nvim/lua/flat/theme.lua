-- Shared implementation of the flatwhite / flatblack colourschemes.
--
-- Both came from Helix's `flatwhite` theme (runtime/themes/flatwhite.toml),
-- which in turn was adopted from https://github.com/biletskyy/flatwhite-syntax.
-- flatblack is the dark counterpart: the same idea of colouring *backgrounds*
-- of tokens instead of their foregrounds, with a warm dark palette.
--
-- Helix resolves a scope by walking up its dotted name (`string.escape` ->
-- `string`) and the child entry *replaces* the parent style.  Every style
-- below is written with that resolution already applied:
--
--   keyword / string / constant / attribute / namespace / parameter  -> pastel bg
--   function                                                        -> bold
--   type, variable, operator, punctuation, property, constructor    -> base1
--   comment                                                         -> base3 italic
--   doc comment                                                     -> base2
--
-- Neovim-specific notes:
--   * `constant.character.escape` is `@string.escape`, so escapes are blue
--     (not green) inside strings, like in Helix.
--   * `namespace` -> `@namespace` / `@module`; `variable.other.member` ->
--     `@variable.member`.
--   * Neovim cannot distinguish `comment.line` from `comment`; Helix's
--     `comment.line = {}` quirk is folded into `@comment`.
--   * Neovim has no locals-driven highlighting; the few LSP semantic tokens
--     that are kept (parameters) restore part of that behaviour.
--   * The cursor is recoloured on every move (`flat.cursor`): its background
--     becomes the colour of the token under it, so the block always matches
--     the symbol instead of being a fixed black/white square.

local M = {}

---@param name string  name of the colourscheme (`flatwhite` / `flatblack`)
---@param p table     palette, see lua/flat/white.lua and lua/flat/black.lua
function M.apply(name, p)
  local blue = { fg = p.blue_text, bg = p.blue_bg }
  local green = { fg = p.green_text, bg = p.green_bg }
  local purple = { fg = p.purple_text, bg = p.purple_bg }
  local teal = { fg = p.teal_text, bg = p.teal_bg }
  local orange = { fg = p.orange_text, bg = p.orange_bg }

  local function hi(groups)
    for name, spec in pairs(groups) do
      if type(spec) == 'string' then
        spec = { link = spec }
      end
      vim.api.nvim_set_hl(0, name, spec)
    end
  end

  vim.o.background = p.background or 'light'
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
  end
  vim.g.colors_name = name

  -- ============================================================================
  -- Editor UI (helix ui.* scopes)
  -- ============================================================================

  hi({
    Normal        = { fg = p.base1, bg = p.base7 },
    NormalNC      = { fg = p.base1, bg = p.base7 }, -- helix does not dim inactive windows
    NormalFloat   = { fg = p.base1, bg = p.base6 }, -- ui.popup
    FloatNormal   = { link = 'NormalFloat' },
    FloatBorder   = { fg = p.base3, bg = p.base6 },
    FloatTitle    = { fg = p.base1, bg = p.base6, bold = true },
    FloatFooter   = { fg = p.base2, bg = p.base6 },

    -- ui.cursor / ui.cursor.primary: fg base1, bg base7, reversed
    Cursor        = { fg = p.cursor_fg, bg = p.cursor_bg },
    lCursor       = { link = 'Cursor' },
    CursorIM      = { link = 'Cursor' },
    TermCursor    = { link = 'Cursor' },

    CursorLine    = { bg = p.base6 }, -- ui.cursorline
    CursorColumn  = { bg = p.base6 },
    ColorColumn   = { bg = p.base6 }, -- ui.virtual.ruler

    LineNr        = { fg = p.base1, bg = p.base6 }, -- ui.linenr
    LineNrAbove   = { fg = p.base1, bg = p.base6 },
    LineNrBelow   = { fg = p.base1, bg = p.base6 },
    CursorLineNr  = { fg = p.base6, bg = p.base1 }, -- ui.linenr.selected, reversed
    SignColumn    = { bg = p.base6 },
    CursorLineSign = { bg = p.base6 },
    CursorLineFold = { bg = p.base6 },
    FoldColumn    = { fg = p.base2, bg = p.base6 },
    Folded        = { fg = p.base2, bg = p.base6 },

    EndOfBuffer   = { fg = p.base5 },
    NonText       = { fg = p.base4 },
    Whitespace    = { fg = p.base5 }, -- ui.virtual.whitespace
    SpecialKey    = { fg = p.base4 },
    Conceal       = { fg = p.base1, bg = p.base7 },
    Directory     = { fg = p.teal_text },

    Title         = { fg = purple.fg, bg = purple.bg, bold = true }, -- markup.heading

    -- ui.selection.primary
    -- Выделение инвертирует цвета каждого токена: фоном становится его
    -- foreground, а текст — его background (как reverse в терминале).
    Visual        = { reverse = true },
    VisualNOS     = { link = 'Visual' },

    Search        = { fg = p.base6, bg = p.base2 }, -- ui.selection.primary (solid)
    IncSearch     = { fg = p.base7, bg = p.base1 },
    CurSearch     = { fg = p.base7, bg = p.base1, bold = true },
    Substitute    = { fg = p.base6, bg = p.base2 },
    MatchParen    = { fg = p.matchparen_fg, bg = p.matchparen_bg, bold = true }, -- ui.cursor.match, reversed
    QuickFixLine  = { bg = p.base4 },

    -- ui.menu / ui.menu.selected (reversed)
    Pmenu         = { fg = p.base1, bg = p.base6 },
    PmenuSel      = { fg = p.base6, bg = p.base1 },
    PmenuKind     = { fg = p.base2, bg = p.base6 },
    PmenuKindSel  = { fg = p.base4, bg = p.base1 },
    PmenuExtra    = { fg = p.base2, bg = p.base6 },
    PmenuExtraSel = { fg = p.base4, bg = p.base1 },
    PmenuMatch    = { fg = p.purple_text, bg = p.base6, bold = true },
    PmenuMatchSel = { fg = p.purple_bg, bg = p.base1, bold = true },
    PmenuSbar     = { bg = p.base5 },
    PmenuThumb    = { bg = p.base3 },
    PmenuBorder   = { fg = p.base3, bg = p.base6 },
    PmenuShadow   = { bg = p.base4 },
    WildMenu      = { link = 'PmenuSel' },

    MsgArea       = { fg = p.base1, bg = p.base7 },
    MsgSeparator  = { fg = p.base4, bg = p.base6 },

    -- ui.statusline / ui.statusline.inactive
    StatusLine     = { fg = p.sl_fg, bg = p.sl_bg, bold = true },
    StatusLineNC   = { fg = p.sl_nc_fg, bg = p.sl_nc_bg },
    StatusLineTerm = { link = 'StatusLine' },
    StatusLineTermNC = { link = 'StatusLineNC' },
    WinBar         = { fg = p.base1, bg = p.base6, bold = true },
    WinBarNC       = { fg = p.base2, bg = p.base6 },

    WinSeparator  = { fg = p.base4, bg = p.base7 },
    VertSplit     = { link = 'WinSeparator' },

    TabLine       = { fg = p.base1, bg = p.base6 },
    TabLineSel    = { fg = p.base7, bg = p.base1, bold = true },
    TabLineFill   = { bg = p.base6 },

    ErrorMsg      = { fg = p.diff_delete, bold = true },
    WarningMsg    = { fg = p.orange_text },
    MoreMsg       = { fg = p.orange_text },
    Question      = { fg = p.teal_text },
    ModeMsg       = { fg = p.base1, bold = true },

    SpellBad      = { sp = p.diff_delete, undercurl = true },
    SpellCap      = { sp = p.orange_text, undercurl = true },
    SpellRare     = { sp = p.blue_text_sec, undercurl = true },
    SpellLocal    = { sp = p.teal_text_sec, undercurl = true },

    -- diff.plus / diff.delta / diff.minus
    DiffAdd       = { bg = p.green_bg },
    DiffChange    = { bg = p.orange_bg },
    DiffDelete    = { fg = p.diff_delete, bg = p.base4 },
    DiffText      = { fg = p.base6, bg = p.base2 },
    diffAdded     = { fg = p.diff_add },
    diffRemoved   = { fg = p.diff_delete },
    diffChanged   = { fg = p.diff_change },
    diffNewFile   = { fg = p.diff_add },
    diffOldFile   = { fg = p.diff_delete },
    diffFile      = { fg = p.blue_text },
    diffLine      = { fg = p.base2 },
    diffIndexLine = { fg = p.base3 },

    Terminal      = { fg = p.base1, bg = p.base7 },
  })

  -- ============================================================================
  -- Diagnostics (helix diagnostic.*, error/warning/info scopes)
  -- ============================================================================

  hi({
    DiagnosticError   = { fg = p.diff_delete },
    DiagnosticWarn    = { fg = p.orange_text },
    DiagnosticInfo    = { fg = p.orange_text }, -- flatwhite uses the same colour for info and warning
    DiagnosticHint    = { fg = p.base2 },
    DiagnosticOk      = { fg = p.diff_add },

    DiagnosticUnderlineError = { sp = p.diff_delete, undercurl = true },
    DiagnosticUnderlineWarn  = { sp = p.orange_text, undercurl = true },
    DiagnosticUnderlineInfo  = { sp = p.orange_text_sec, undercurl = true },
    DiagnosticUnderlineHint  = { sp = p.base2, undercurl = true },
    DiagnosticUnderlineOk    = { sp = p.diff_add, undercurl = true },

    DiagnosticVirtualTextError = { fg = p.diff_delete },
    DiagnosticVirtualTextWarn  = { fg = p.orange_text, bg = p.orange_bg },
    DiagnosticVirtualTextInfo  = { fg = p.orange_text, bg = p.orange_bg },
    DiagnosticVirtualTextHint  = { fg = p.base2 },
    DiagnosticVirtualTextOk    = { fg = p.diff_add },

    DiagnosticFloatingError = { fg = p.diff_delete, bg = p.base6 },
    DiagnosticFloatingWarn  = { fg = p.orange_text, bg = p.base6 },
    DiagnosticFloatingInfo  = { fg = p.orange_text, bg = p.base6 },
    DiagnosticFloatingHint  = { fg = p.base2, bg = p.base6 },
    DiagnosticFloatingOk    = { fg = p.diff_add, bg = p.base6 },

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
    LspInlayHint = { fg = p.base3, italic = true }, -- ui.virtual.inlay-hint
    LspCodeLens = { fg = p.base3, italic = true },
    LspCodeLensSeparator = { fg = p.base4 },
  })

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

  -- ============================================================================
  -- Plugins
  -- ============================================================================

  -- gitsigns (helix diff.plus/delta/minus signs)
  hi({
    GitSignsAdd        = { fg = p.diff_add },
    GitSignsChange     = { fg = p.diff_change },
    GitSignsDelete     = { fg = p.diff_delete },
    GitSignsTopdelete  = { fg = p.diff_delete },
    GitSignsChangedelete = { fg = p.diff_change },
    GitSignsUntracked  = { fg = p.green_text_sec },
    GitSignsAddNr      = { fg = p.diff_add },
    GitSignsChangeNr   = { fg = p.diff_change },
    GitSignsDeleteNr   = { fg = p.diff_delete },
    GitSignsTopdeleteNr = { fg = p.diff_delete },
    GitSignsChangedeleteNr = { fg = p.diff_change },
    GitSignsUntrackedNr = { fg = p.green_text_sec },
    GitSignsAddLn      = { bg = p.green_bg },
    GitSignsChangeLn   = { bg = p.orange_bg },
    GitSignsDeleteLn   = { bg = p.base4 },
    GitSignsCurrentLineBlame = { fg = p.base3, italic = true },
  })

  -- indent guides
  hi({
    IblIndent          = { fg = p.base5 },
    IblWhitespace      = { fg = p.base5 },
    IblScope           = { fg = p.base4 },
    IndentBlanklineChar = { link = 'IblIndent' },
    IndentBlanklineSpaceChar = { link = 'IblWhitespace' },
    IndentBlanklineContextChar = { link = 'IblScope' },
    MiniIndentscopeSymbol = { fg = p.base4 },
    MiniIndentscopeSymbolOff = { fg = p.base5 },
    MiniIndentscopeSymbolWithStartScope = { fg = p.base3 },
  })

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

  -- neo-tree
  hi({
    NeoTreeNormal          = { fg = p.base1, bg = p.base7 },
    NeoTreeNormalNC        = { fg = p.base1, bg = p.base7 },
    NeoTreeEndOfBuffer     = { fg = p.base7 },
    NeoTreeWinSeparator    = { fg = p.base4, bg = p.base7 },
    NeoTreeFloatBorder     = { fg = p.base3, bg = p.base6 },
    NeoTreeFloatTitle      = { fg = p.base1, bg = p.base6, bold = true },
    NeoTreeTitleBar        = { fg = p.base7, bg = p.base1, bold = true },
    NeoTreeRootName        = { fg = p.base1, bold = true },
    NeoTreeDirectoryName   = { fg = p.teal_text },
    NeoTreeDirectoryIcon   = { fg = p.teal_text },
    NeoTreeFileIcon        = { fg = p.base2 },
    NeoTreeFileName        = { fg = p.base1 },
    NeoTreeFileNameOpened  = { fg = p.purple_text, bold = true },
    NeoTreeFileStats       = { fg = p.base2 },
    NeoTreeFileStatsHeader = { fg = p.base2, bold = true },
    NeoTreeIndentMarker    = { fg = p.base4 },
    NeoTreeExpander        = { fg = p.base3 },
    NeoTreeCursorLine      = { bg = p.base6 },
    NeoTreeGitAdded        = { fg = p.diff_add },
    NeoTreeGitModified     = { fg = p.diff_change },
    NeoTreeGitDeleted      = { fg = p.diff_delete },
    NeoTreeGitRenamed      = { fg = p.diff_renamed },
    NeoTreeGitUntracked    = { fg = p.green_text_sec },
    NeoTreeGitIgnored      = { fg = p.base3 },
    NeoTreeModified        = { fg = p.orange_text },
    NeoTreeDimText         = { fg = p.base3 },
    NeoTreeDotfile         = { fg = p.base2 },
    NeoTreeHiddenByName    = { fg = p.base3 },
    NeoTreeMessage         = { fg = p.base2 },
    NeoTreeSymbolicLinkTarget = { fg = p.blue_text_sec },
  })

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

  -- nvim-dap-ui / nvim-dap-virtual-text
  hi({
    DapUINormal            = { fg = p.base1, bg = p.base7 },
    DapUINormalNC          = { fg = p.base1, bg = p.base7 },
    DapUIEndOfBuffer       = { fg = p.base7 },
    DapUIEndofBuffer       = { fg = p.base7 },
    DapUIFloatNormal       = { fg = p.base1, bg = p.base6 },
    DapUIFloatBorder       = { fg = p.base3, bg = p.base6 },
    DapUIWinSelect         = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    DapUIDecoration        = { fg = p.base2 },
    DapUIScope             = { fg = p.teal_text },
    DapUIModifiedValue     = { fg = p.diff_change, bold = true },
    DapUIPlayPause         = { fg = p.diff_add },
    DapUIPlayPauseNC       = { fg = p.base3 },
    DapUIRestart           = { fg = p.blue_text },
    DapUIRestartNC         = { fg = p.base3 },
    DapUIStop              = { fg = p.diff_delete },
    DapUIStopNC            = { fg = p.base3 },
    DapUIUnavailable       = { fg = p.base3 },
    DapUIUnavailableNC     = { fg = p.base4 },
    DapUIStepOver          = { fg = p.blue_text },
    DapUIStepOverNC        = { fg = p.base3 },
    DapUIStepInto          = { fg = p.blue_text },
    DapUIStepIntoNC        = { fg = p.base3 },
    DapUIStepOut           = { fg = p.blue_text },
    DapUIStepOutNC         = { fg = p.base3 },
    DapUIStepBack          = { fg = p.blue_text },
    DapUIStepBackNC        = { fg = p.base3 },
    DapUIWatchesEmpty      = { fg = p.base3 },
    DapUIWatchesValue      = { fg = p.diff_add },
    DapUIWatchesError      = { fg = p.diff_delete },
    DapUIBreakpointsPath   = { fg = p.teal_text },
    DapUIBreakpointsInfo   = { fg = p.blue_text },
    DapUIBreakpointsLine   = { fg = p.base2 },
    DapUIBreakpointsCurrentLine = { fg = p.base1, bold = true },
    DapUIBreakpointsDisabledLine = { fg = p.base3 },
    DapUIThread            = { fg = p.teal_text },
    DapUIStoppedThread     = { fg = p.purple_text },
    DapUIFrameName         = { fg = p.base1 },
    DapUICurrentFrameName  = { fg = p.base1, bold = true },
    DapUISource            = { fg = p.blue_text_sec },
    DapUILineNumber        = { fg = p.base2 },
    DapUIValue             = { fg = p.blue_text },
    DapUIVariable          = { fg = p.base1 },
    DapUIType              = { fg = p.teal_text },
    DapVirtualText         = { fg = p.base3, italic = true },
    DapVirtualTextChanged  = { fg = p.orange_text, italic = true },
  })

  -- lazy.nvim
  hi({
    LazyNormal       = { fg = p.base1, bg = p.base6 },
    LazyFloat        = { fg = p.base1, bg = p.base6 },
    LazyFloatOptions = { fg = p.base1, bg = p.base6 },
    LazyFloatResized = { fg = p.base2, bg = p.base5 },
    LazyButton       = { fg = p.base1, bg = p.base5 },
    LazyButtonActive = { fg = p.base6, bg = p.base1, bold = true },
    LazyH1           = { fg = p.base7, bg = p.base1, bold = true },
    LazyH2           = { fg = p.purple_text, bg = p.purple_bg, bold = true },
    LazySpecial      = { fg = p.purple_text },
    LazyComment      = { fg = p.base2, italic = true },
    LazyDimmed       = { fg = p.base3 },
    LazyProgressDone = { fg = p.diff_add, bold = true },
    LazyProgressTodo = { fg = p.base4 },
    LazyUrl          = { fg = p.blue_text, underline = true },
    LazyValue        = { fg = p.orange_text },
    LazyError        = { fg = p.diff_delete },
    LazyWarning      = { fg = p.orange_text_sec },
    LazyCommit       = { fg = p.base2 },
    LazyCommitType   = { fg = p.purple_text },
    LazyCommitScope  = { fg = p.teal_text },
    LazyCommitIssue  = { fg = p.blue_text_sec },
    LazyDir          = { fg = p.teal_text },
    LazyLocal        = { fg = p.orange_text_sec },
    LazyNoCond       = { fg = p.diff_delete },
    LazyDepList      = { fg = p.base2 },
    LazyTaskOutput   = { fg = p.base2 },
    LazyProp         = { fg = p.base2 },
  })

  -- spectre
  hi({
    SpectreBody       = { fg = p.base1, bg = p.base6 },
    SpectreBorder     = { fg = p.base3, bg = p.base6 },
    SpectreFile       = { fg = p.teal_text },
    SpectreDir        = { fg = p.base2 },
    SpectreSearch     = { fg = p.base6, bg = p.base2 },
    SpectreReplace    = { fg = p.purple_text, bg = p.purple_bg },
    SpectrePath       = { fg = p.base2 },
    SpectreHeader     = { fg = p.base2 },
    SpectreQuery      = { fg = p.base1, bold = true },
    SpectreConfig     = { fg = p.base2 },
    SpectrePanelWrite = { fg = p.diff_change },
    SpectreState      = { fg = p.base3 },
    SpectreStateOpened = { fg = p.orange_text },
  })

  -- snacks.nvim notifier
  hi({
    SnacksNotifier            = { fg = p.base1, bg = p.base6 },
    SnacksNotifierMinimal     = { fg = p.base1, bg = p.base6 },
    SnacksNotifierBorder      = { fg = p.base3, bg = p.base6 },
    SnacksNotifierTitle       = { fg = p.base1, bold = true },
    SnacksNotifierIcon        = { fg = p.base2 },
    SnacksNotifierFooter      = { fg = p.base2 },
    SnacksNotifierHistory     = { fg = p.base1, bg = p.base6 },
    SnacksNotifierHistoryTitle = { fg = p.base1, bold = true },
    SnacksNotifierHistoryDateTime = { fg = p.base2 },
  })

  for level, color in pairs({
    Error = p.diff_delete,
    Warn = p.orange_text,
    Info = p.blue_text,
    Debug = p.base2,
    Trace = p.base3,
  }) do
    hi({
      ['SnacksNotifier' .. level] = { fg = color },
      ['SnacksNotifierTitle' .. level] = { fg = color, bold = true },
      ['SnacksNotifierIcon' .. level] = { fg = color },
      ['SnacksNotifierBorder' .. level] = { fg = p.base3, bg = p.base6 },
      ['SnacksNotifierFooter' .. level] = { fg = color },
    })
  end

  -- ============================================================================
  -- Terminal colours (palette-derived)
  -- ============================================================================

  vim.g.terminal_ansi_colors = p.ansi

  -- Курсор: в Neovide есть нативный режим, который берёт цвета клетки под
  -- курсором (если у Cursor не заданы fg/bg). В остальных UI пересчитываем
  -- группу Cursor на каждом перемещении (см. lua/flat/cursor.lua).
  if vim.g.neovide then
    vim.g.neovide_cursor_cell_color_fallback = true
    vim.api.nvim_set_hl(0, 'Cursor', {})
    vim.api.nvim_set_hl(0, 'TermCursor', {})
  else
    require('flat.cursor').attach()
  end
end

return M
