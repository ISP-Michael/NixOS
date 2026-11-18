local P = require('pack')
local M = {}

local function fzf()
  P.use('fzf-lua')
  return require('fzf-lua')
end

function M.files()
  fzf().files(
    {
      cwd = require('core.project').root(),
    }
  )
end

function M.oldfiles()
  fzf().oldfiles()
end

function M.grep()
  fzf().grep(
    {
      cwd = require('core.project').root(),
    }
  )
end

function M.buffers()
  fzf().buffers()
end

P.register(
  'fzf-lua',
  function()
    P.load('nvim-web-devicons')
    P.load('fzf-lua')
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
          header = ' tab/shift-tab select · ctrl-a all · ctrl-d none · ctrl-x delete ',
          keymap = {
            fzf = {
              ['ctrl-a'] = 'select-all',
              ['ctrl-d'] = 'deselect-all',
              ['ctrl-space'] = 'toggle+down',
            },
          },
          -- Delete selected buffers and reload the list in place, so the
          -- picker stays open for more deletions and navigation.
          actions = {
            ['ctrl-x'] = {
              fn = require('fzf-lua').actions.buf_del,
              reload = true,
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
)

vim.keymap.set(
  'n',
  '<leader>ff',
  M.files,
  {
    desc = 'Files (fzf)'
  }
)
vim.keymap.set(
  'n',
  '<leader>fo',
  M.oldfiles,
  {
    desc = 'Recent files (fzf)'
  }
)
vim.keymap.set(
  'n',
  '<leader>fb',
  M.buffers,
  {
    desc = 'Buffers (fzf)'
  }
)
vim.keymap.set(
  'n',
  '<leader>fg',
  M.grep,
  {
    desc = 'Grep project (fzf)'
  }
)

return M
