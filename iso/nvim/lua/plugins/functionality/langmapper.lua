return {
  'Wansmer/langmapper.nvim',
  lazy = false,
  priority = 50,
  config = function()
    require('langmapper').setup()
  end
}
