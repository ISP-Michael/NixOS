return {
  'datsfilipe/vesper.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('vesper').setup(
      {

      }
    )
    vim.cmd.colorscheme('vesper')
  end
}
