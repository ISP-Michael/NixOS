return {
  'kndndrj/nvim-dbee',
  lazy = true,
  ft = {
    'sql'
  },
  dependencies = {
    'MunifTanjim/nui.nvim'
  },
  build = false,
  config = function()
    require('dbee').setup()
  end
}
