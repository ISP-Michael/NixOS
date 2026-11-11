-- Attach on the first real file instead of during init.  gitsigns scans the
-- repository on attach, which is pure overhead when Neovim starts empty.
local P = require('pack')

local loaded = false

local function setup()
  if loaded then
    return
  end
  loaded = true

  P.load('gitsigns.nvim')
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

P.register('gitsigns.nvim', setup)

-- Scratch files outside a repository do not need the plugin at all.  Keep the
-- autocmd active so the first file that is inside .git loads it.
local function maybe_setup()
  local name = vim.api.nvim_buf_get_name(0)
  if name == '' then
    return
  end
  if not vim.fs.root(name, '.git') then
    return
  end
  setup()
end

vim.api.nvim_create_autocmd(
  {
    'BufReadPost',
    'BufNewFile',
  },
  {
    callback = maybe_setup,
  }
)

return {}
