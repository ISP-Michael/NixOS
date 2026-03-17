vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN]  = '',
      [vim.diagnostic.severity.INFO]  = '',
      [vim.diagnostic.severity.HINT]  = ''
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'Macro',
      [vim.diagnostic.severity.WARN]  = 'Float',
      [vim.diagnostic.severity.INFO]  = 'Constant',
      [vim.diagnostic.severity.HINT]  = 'Define'
    }
  },
  virtual_text  = { prefix = '●', },
  float         = { border = 'rounded' },
  severity_sort = true
})

