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
          style_preset = bufferline.style_preset.no_italic,
          show_buffer_icons = false,
          separator_style = 'slope',
          diagnostics = 'nvim_lsp',
          themable = true
        }
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
