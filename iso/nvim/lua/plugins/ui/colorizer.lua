return {
  'norcalli/nvim-colorizer.lua',
  ft = {
    'html',
    'css',
    'js',
    'ts'
  },
  config = function()
    require('colorizer').setup()
  end
}
