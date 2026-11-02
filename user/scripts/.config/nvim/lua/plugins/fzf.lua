return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons'
  },
  keys = {
    {
      '<leader>ff',
      ':lua require("fzf-lua").files()<CR>'
    },
    {
      '<leader>fo',
      ':lua require("fzf-lua").oldfiles()<cr>'
    },
    {
      '<leader>fb',
      ':lua require("fzf-lua").buffers()<CR>'
    },
  },
  config = function()
    require('fzf-lua').setup(
      {
        winopts = {
          height = 0.90,
          width = 0.90,
          row = 0.50,
          preview = {
            layout = 'horizontal',
            horizontal = 'right:50%',
          },
        },
        files = {
          previewer = false,
          file_icons = true,
        },
        oldfiles = {
          previewer = false,
          file_icons = true,
        },
        buffers = {
          previewer = false,
          file_icons = true,
          sort_lastused = true,
          ignore_current_buffer = false,
          _headers = {},
          actions = {
            ['ctrl-x'] = {
              require('fzf-lua').actions.buf_del,
              require('fzf-lua').actions.resume,
            },
          },
        },
        lsp = {
          file_icons = true,
          icons = true,
        },
        grep = {
          file_icons = true,
          previewer = false,
        },
      }
    )
  end
}
