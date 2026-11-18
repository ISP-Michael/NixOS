vim.diagnostic.config(
  {
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = '',
        [vim.diagnostic.severity.WARN] = '',
        [vim.diagnostic.severity.INFO] = '',
        [vim.diagnostic.severity.HINT] = '',
      },
    },
    virtual_text  = {
      prefix = '●',
    },
    float = {
      border = 'rounded'
    },
    severity_sort = true
  }
)

