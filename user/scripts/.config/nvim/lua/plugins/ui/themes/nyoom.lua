return {
  'nyoom-engineering/oxocarbon.nvim',
  lazy = false,
  priority = 1000,
  build = false,
  config = function()
    vim.o.background = 'dark'
    vim.cmd.colorscheme('oxocarbon')
  end
}
