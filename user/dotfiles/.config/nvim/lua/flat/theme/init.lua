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
--
-- The sections live in lua/flat/theme/{ui,diagnostics,syntax,treesitter,
-- lsp,plugins,terminal}.lua; `flat/theme.lua` is the compatibility entry.
local M = {}

---@param name string  name of the colourscheme (`flatwhite` / `flatblack`)
---@param p table     palette, see lua/flat/white.lua and lua/flat/black.lua
function M.apply(name, p)
  local colors = {
    blue = { fg = p.blue_text, bg = p.blue_bg },
    green = { fg = p.green_text, bg = p.green_bg },
    purple = { fg = p.purple_text, bg = p.purple_bg },
    teal = { fg = p.teal_text, bg = p.teal_bg },
    orange = { fg = p.orange_text, bg = p.orange_bg },
  }

  local function hi(groups)
    for group, spec in pairs(groups) do
      if type(spec) == 'string' then
        spec = { link = spec }
      end
      vim.api.nvim_set_hl(0, group, spec)
    end
  end

  vim.o.background = p.background or 'light'
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
  end
  vim.g.colors_name = name

  require('flat.theme.ui')(hi, p, colors)
  require('flat.theme.diagnostics')(hi, p, colors)
  require('flat.theme.syntax')(hi, p, colors)
  require('flat.theme.treesitter')(hi, p, colors)
  require('flat.theme.lsp')(hi, p, colors)
  require('flat.theme.plugins')(hi, p, colors)
  require('flat.theme.terminal')(hi, p, colors)

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

  require('flat.strings').attach()
end

return M
