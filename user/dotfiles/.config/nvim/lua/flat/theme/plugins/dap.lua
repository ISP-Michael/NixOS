return function(hi, p, colors)
  local blue = colors.blue
  local green = colors.green
  local purple = colors.purple
  local teal = colors.teal
  local orange = colors.orange

  -- nvim-dap-ui / nvim-dap-virtual-text
  hi({
    DapUINormal            = {
      fg = p.base1,
      bg = p.base7
    },
    DapUINormalNC          = {
      fg = p.base1,
      bg = p.base7
    },
    DapUIEndOfBuffer       = { fg = p.base7 },
    DapUIEndofBuffer       = { fg = p.base7 },
    DapUIFloatNormal       = {
      fg = p.base1,
      bg = p.base6
    },
    DapUIFloatBorder       = {
      fg = p.base3,
      bg = p.base6
    },
    DapUIWinSelect         = {
      fg = p.purple_text,
      bg = p.purple_bg,
      bold = true
    },
    DapUIDecoration        = { fg = p.base2 },
    DapUIScope             = { fg = p.teal_text },
    DapUIModifiedValue     = {
      fg = p.diff_change,
      bold = true
    },
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
    DapUIBreakpointsCurrentLine = {
      fg = p.base1,
      bold = true
    },
    DapUIBreakpointsDisabledLine = { fg = p.base3 },
    DapUIThread            = { fg = p.teal_text },
    DapUIStoppedThread     = { fg = p.purple_text },
    DapUIFrameName         = { fg = p.base1 },
    DapUICurrentFrameName  = {
      fg = p.base1,
      bold = true
    },
    DapUISource            = { fg = p.blue_text_sec },
    DapUILineNumber        = { fg = p.base2 },
    DapUIValue             = { fg = p.blue_text },
    DapUIVariable          = { fg = p.base1 },
    DapUIType              = { fg = p.teal_text },
    DapVirtualText         = {
      fg = p.base3,
      italic = true
    },
    DapVirtualTextChanged  = {
      fg = p.orange_text,
      italic = true
    },
  })
end
