local set = vim.keymap.set

set(
  'n',
  '<C-s>',
  '<cmd>write<CR>',
  {
    desc = 'Save buffer'
  }
)

set(
  'n',
  '<C-q>',
  '<cmd>quit<CR>',
  {
    desc = 'Quit window'
  }
)

set(
  'n',
  '<Esc>',
  '<cmd>nohlsearch<CR>',
  {
    desc = 'Clear search highlight'
  }
)

set(
  't',
  '<C-s>',
  '<C-\\><C-n>',
  {
    desc = 'Exit terminal mode'
  }
)

set(
  't',
  '<C-q>',
  '<C-\\><C-n><Cmd>close<CR>',
  {
    desc = 'Exit terminal mode and close window'
  }
)

set(
  'n',
  '<leader>dq',
  function()
    require('dap').terminate()
    require('dapui').close()
  end,
  {
    desc = 'Stop debugging and close UI'
  }
)

set(
  'n',
  '<leader>bb',
  function()
    require('fzf-lua').buffers()
  end,
  {
    desc = 'Buffers (fzf)'
  }
)

set(
  'n',
  '<leader>bd',
  function()
    local current = vim.api.nvim_get_current_buf()
    vim.cmd('bprevious')
    vim.cmd('bdelete ' .. current)
  end,
  {
    desc = 'Close current buffer'
  }
)

set(
  'n',
  '<M-j>',
  '<cmd>bnext<CR>',
  {
    desc = 'Next buffer'
  }
)

set(
  'n',
  '<M-k>',
  '<cmd>bprevious<CR>',
  {
    desc = 'Previous buffer'
  }
)

vim.api.nvim_create_autocmd(
  {
    'LspAttach'
  },
  {
    callback = function(event)
      local buf = vim.lsp.buf

      set(
        'n',
        'gd',
        buf.definition,
        {
          buffer = event.buf,
          desc = 'LSP: go to definition'
        }
      )

      set(
        'n',
        'gD',
        buf.declaration,
        {
          buffer = event.buf,
          desc = 'LSP: go to declaration'
        }
      )

      set(
        'n',
        'K',
        buf.hover,
        {
          buffer = event.buf,
          desc = 'LSP: hover'
        }
      )
    end
  }
)
