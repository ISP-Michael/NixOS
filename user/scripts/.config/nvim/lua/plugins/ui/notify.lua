return {
  'folke/snacks.nvim',
  lazy = false,
  priority = 100,
  opts = {
    notifier = {
      enabled = true,
      timeout = 3000,
    },
  },
  config = function(_, opts)
    require('snacks').setup(opts)
  end
}
