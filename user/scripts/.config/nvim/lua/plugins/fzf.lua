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
      '<leader>fc',
      function()
        local fzf = require('fzf-lua')
        local quick_dirs = {
          '~/.config',
          '~/Downloads',
          '~/Projects',
          '~',
          vim.fn.getcwd(),
          '/etc'
        }
        fzf.fzf_exec(
          quick_dirs,
          {
            actions = {
              ['default'] = function(selected)
                if #selected > 0 then
                  fzf.files(
                    {
                      cwd = selected[1]
                    }
                  )
                end
              end
            }
          }
        )
      end
    },
    {
      '<leader>fg',
      ':lua require("fzf-lua").live_grep()<CR>'
    },
    {
      '<leader>fw',
      ':lua require("fzf-lua").grep_cword()<CR>'
    },
    {
      '<leader>fb',
      ':lua require("fzf-lua").buffers()<CR>'
    },
    {
      '<leader>de',
      ':lua require("fzf-lua").diagnostics_workspace()<CR>'
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
          previewer = true,
          file_icons = true,
        },
        oldfiles = {
          previewer = true,
          file_icons = true,
        },
        buffers = {
          previewer = true,
          file_icons = true,
          actions = {
            ['ctrl-x'] = {
              require('fzf-lua').actions.buf_del,
              require('fzf-lua').actions.resume,
            }
          }
        },
        lsp = {
          file_icons = true,
          icons = true,
        },
        grep = {
          file_icons = true,
          previewer = true,
        },
      }
    )
  end
}
