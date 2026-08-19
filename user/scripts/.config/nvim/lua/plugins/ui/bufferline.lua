return {
  'akinsho/bufferline.nvim',
  lazy = false,
  branch = 'main',
  priority = 1000,
  config = function()
    local bufferline = require('bufferline')
    bufferline.setup(
      {
        options = {
          show_buffer_icons = false,
          separator_style = 'slant',
          diagnostics = 'nvim_lsp',
          style_preset = bufferline.style_preset.no_italic
        }
      }
    )
    require('bufferline.constants').sep_chars.slant = { string.char(0xee, 0x82, 0xb6), string.char(0xee, 0x82, 0xb4) }
    local function apply_bufferline_colors()
      local ok, p = pcall(function() return require('zen.colors').get().palette end)
      if not ok then return end
      local strip = p.bg1
      local pill = p.bg0
      vim.api.nvim_set_hl(0, 'BufferLineFill', { bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineBackground', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineBuffer', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineBufferVisible', { fg = p.slate, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineBufferSelected', { fg = p.slate, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineCloseButton', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineCloseButtonVisible', { fg = p.slate, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineCloseButtonSelected', { fg = p.slate, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineNumbers', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineNumbersVisible', { fg = p.slate, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineNumbersSelected', { fg = p.slate, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineModified', { fg = p.vcs_changed, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineModifiedVisible', { fg = p.vcs_changed, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineModifiedSelected', { fg = p.vcs_changed, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineDuplicate', { fg = p.fg_muted, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineDuplicateVisible', { fg = p.fg_muted, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineDuplicateSelected', { fg = p.fg_muted, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineIndicator', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineIndicatorVisible', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineIndicatorSelected', { fg = p.ash, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineGroupLabel', { fg = pill, bg = p.ash })
      vim.api.nvim_set_hl(0, 'BufferLineGroupSeparator', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineOffsetSeparator', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineTruncMarker', { fg = p.fg_muted, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineTab', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineTabClose', { fg = p.ash, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineTabSelected', { fg = p.slate, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineDiagnostic', { fg = p.diag_ok, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineDiagnosticVisible', { fg = p.diag_ok, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineDiagnosticSelected', { fg = p.diag_ok, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineError', { fg = p.diag_error, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineErrorVisible', { fg = p.diag_error, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineErrorSelected', { fg = p.diag_error, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineErrorDiagnostic', { fg = p.diag_error, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineErrorDiagnosticVisible', { fg = p.diag_error, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineErrorDiagnosticSelected', { fg = p.diag_error, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineWarning', { fg = p.diag_warn, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineWarningVisible', { fg = p.diag_warn, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineWarningSelected', { fg = p.diag_warn, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineWarningDiagnostic', { fg = p.diag_warn, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineWarningDiagnosticVisible', { fg = p.diag_warn, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineWarningDiagnosticSelected', { fg = p.diag_warn, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineInfo', { fg = p.diag_info, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineInfoVisible', { fg = p.diag_info, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineInfoSelected', { fg = p.diag_info, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineInfoDiagnostic', { fg = p.diag_info, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineInfoDiagnosticVisible', { fg = p.diag_info, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineInfoDiagnosticSelected', { fg = p.diag_info, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineHint', { fg = p.diag_hint, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineHintVisible', { fg = p.diag_hint, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineHintSelected', { fg = p.diag_hint, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineHintDiagnostic', { fg = p.diag_hint, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineHintDiagnosticVisible', { fg = p.diag_hint, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineHintDiagnosticSelected', { fg = p.diag_hint, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineSeparator', { fg = strip, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineSeparatorVisible', { fg = strip, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineSeparatorSelected', { fg = strip, bg = pill })
      vim.api.nvim_set_hl(0, 'BufferLineTabSeparator', { fg = strip, bg = strip })
      vim.api.nvim_set_hl(0, 'BufferLineTabSeparatorSelected', { fg = strip, bg = pill })
    end
    apply_bufferline_colors()
    vim.api.nvim_create_autocmd(
      'ColorScheme',
      {
        callback = apply_bufferline_colors
      }
    )
  end,
  keys = {
    {
      '<Tab>',
      ':bnext<cr>'
    },
    {
      '<S-Tab>',
      ':bprevious<cr>'
    },
    {
      '<leader>bd',
      ':bd<cr>'
    },
    {
      '<leader>bD',
      ':BufferLineCloseOthers<cr>'
    }
  }
}
