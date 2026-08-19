return {
  'lewis6991/gitsigns.nvim',
  lazy = false,
  priority = 600,
  config = function()
    local gs = require('gitsigns')
    gs.setup(
      {
        signs = {
          changedelete = {
            text = '─'
          },
        },
        signs_staged = {
          changedelete = {
            text = '─'
          }
        },
        on_attach = function(bufnr)
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(
              mode,
              l,
              r,
              opts
            )
          end
          map(
            'n',
            ']g',
            function()
              gs.nav_hunk('next')
            end
          )
          map(
            'n',
            '[g',
            function()
              gs.nav_hunk('prev')
            end
          )
          map(
            'n',
            ']G',
            function()
              gs.nav_hunk(
                'next',
                {
                  target = 'staged'
                }
              )
            end
          )
          map(
            'n',
            '[G',
            function()
              gs.nav_hunk(
                'prev',
                {
                  target = 'staged'
                }
              )
            end
          )
          map(
            {
              'o',
              'x'
            },
            'ig',
            ':<C-U>Gitsigns select_hunk<CR>'
          )
          map(
            {
              'o',
              'x'
            },
            'ag',
            ':<C-U>Gitsigns select_hunk<CR>'
          )
        end
      }
    )
  end
}
