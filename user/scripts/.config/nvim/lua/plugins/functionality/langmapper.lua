return {
  'Wansmer/langmapper.nvim',
  event = 'VeryLazy',
  config = function()
    require('langmapper').setup()
  end
}
