return {
  'stevearc/conform.nvim',
  event = {
    'BufWritePre'
  },
  opts = {
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
    },
    format_on_save = {
      timeout_ms = 2000,
      lsp_format = 'never'
    }
  }
}
