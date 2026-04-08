return {
  'akinsho/bufferline.nvim',
  lazy = false,
  priorty = 1000,
  config = function()
    local bufferline = require('bufferline')
    bufferline.setup({
      options = {
        separator_style = 'slant',
        show_buffer_icons = false,
        diagnostics = 'nvim_lsp',
        style_preset = bufferline.style_preset.no_italic
      }
    })
  end,
  keys = {
    { '<Tab>',      ':bnext<cr>' },
    { '<S-Tab>',    ':bprevious<cr>' },
    { '<leader>bd', ':bd<cr>' },
    { '<leader>bD', ':BufferLineCloseOthers<cr>' }
  }
}
