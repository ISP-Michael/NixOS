local P = require('pack')
local M = {}

local function fzf()
  P.use('fzf-lua')
  return require('fzf-lua')
end

function M.files()
  fzf().files()
end

function M.oldfiles()
  fzf().oldfiles()
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

return M
