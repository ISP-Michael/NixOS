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
    require('plugins.dap').terminate()
  end,
  {
    desc = 'Stop debugging and close UI'
  }
)

set(
  'n',
  '<leader>bb',
  function()
    require('plugins.fzf').buffers()
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
    -- Move to the next buffer before deleting the current one.  `:bdelete`
    -- alone selects the alternate buffer, which is not always the next one.
    if not pcall(vim.cmd, 'bnext') then
      vim.cmd('enew')
    end
    local ok, err = pcall(
      vim.api.nvim_buf_delete,
      current,
      {
        force = false,
      }
    )
    if not ok then
      pcall(vim.api.nvim_set_current_buf, current)
      vim.notify(
        tostring(err),
        vim.log.levels.WARN
      )
    end
  end,
  {
    desc = 'Close current buffer and go next'
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
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if not client then
        return
      end
      local buf = vim.lsp.buf

      if client:supports_method('textDocument/definition', event.buf) then
        set(
          'n',
          'gd',
          buf.definition,
          {
            buffer = event.buf,
            desc = 'LSP: go to definition'
          }
        )
      end

      if client:supports_method('textDocument/declaration', event.buf) then
        set(
          'n',
          'gD',
          buf.declaration,
          {
            buffer = event.buf,
            desc = 'LSP: go to declaration'
          }
        )
      end
    end
  }
)
