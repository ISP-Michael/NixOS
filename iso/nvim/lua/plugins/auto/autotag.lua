return {
  'windwp/nvim-ts-autotag',
  lazy = true,
  ft = { 'html', 'xml', 'markdown' },
  config = function()
    require('nvim-ts-autotag').setup()
  end
}
