local P = require('pack')

local opts = {
  formatters_by_ft = {
    python = {
      'ruff_imports',
      'ruff_format'
    },
    go = {
      'gofmt'
    }
  },
  formatters = {
    ruff_imports = {
      command = 'ruff',
      args = {
        'check',
        '--select',
        'I',
        '--fix',
        '--stdin-filename',
        '$FILENAME',
        '-'
      },
      stdin = true
    },
    ruff_format = {
      command = 'ruff',
      args = {
        'format',
        '--stdin-filename',
        '$FILENAME',
        '-'
      },
      stdin = true
    }
  }
}

P.register(
  'conform.nvim',
  function()
    P.load('conform.nvim')
    require('conform').setup(opts)
  end
)

-- Load and format inside the same BufWritePre event.  Letting conform install
-- its own format_on_save autocmd on the first write would miss that write.
vim.api.nvim_create_autocmd(
  'BufWritePre',
  {
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if ft ~= 'python' and ft ~= 'go' then
        return
      end
      P.use('conform.nvim')
      local ok, err = pcall(
        require('conform').format,
        {
          bufnr = args.buf,
          timeout_ms = 2000,
          lsp_format = 'never',
        }
      )
      if not ok then
        vim.notify(
          ('conform: %s'):format(err),
          vim.log.levels.WARN
        )
      end
    end,
  }
)

return {}
