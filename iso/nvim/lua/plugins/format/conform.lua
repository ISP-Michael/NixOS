return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  ft = {

  },
  config = function()
    require('conform').setup({
      formatters_by_ft = {

      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'never'
      }
    })
  end
}
