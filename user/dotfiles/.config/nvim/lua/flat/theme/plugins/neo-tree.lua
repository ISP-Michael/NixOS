return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- neo-tree
  hi({
    NeoTreeNormal          = {
      fg = p.base1,
      bg = p.base7
    },
    NeoTreeNormalNC        = {
      fg = p.base1,
      bg = p.base7
    },
    NeoTreeEndOfBuffer     = { fg = p.base7 },
    NeoTreeWinSeparator    = {
      fg = p.base4,
      bg = p.base7
    },
    NeoTreeFloatBorder     = {
      fg = p.base3,
      bg = p.base6
    },
    NeoTreeFloatTitle      = {
      fg = p.base1,
      bg = p.base6,
      bold = true
    },
    NeoTreeTitleBar        = {
      fg = p.base7,
      bg = p.base1,
      bold = true
    },
    NeoTreeRootName        = {
      fg = p.base1,
      bold = true
    },
    NeoTreeDirectoryName   = { fg = p.teal_text },
    NeoTreeDirectoryIcon   = { fg = p.teal_text },
    NeoTreeFileIcon        = { fg = p.base2 },
    NeoTreeFileName        = { fg = p.base1 },
    NeoTreeFileNameOpened  = {
      fg = p.purple_text,
      bold = true
    },
    NeoTreeFileStats       = { fg = p.base2 },
    NeoTreeFileStatsHeader = {
      fg = p.base2,
      bold = true
    },
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
end
