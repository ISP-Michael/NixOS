return {
  'ibhagwan/fzf-lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons'
  },
  keys = {
    { '<leader>ff', ':lua require("fzf-lua").files()<CR>' },
    { '<leader>fo', ':lua require("fzf-lua").oldfiles()<cr>' },
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
        fzf.fzf_exec(quick_dirs, {
          actions = {
            ['default'] = function(selected)
              if #selected > 0 then
                fzf.files({
                  cwd = selected[1]
                })
              end
            end
          }
        })
      end
    },
  },
  config = function()
    require('fzf-lua').setup({
      files = {
        previewer = false,
        file_icons = false
      },
      oldfiles = {
        previewer = false,
        file_icons = false
      }
    })
  end
}
