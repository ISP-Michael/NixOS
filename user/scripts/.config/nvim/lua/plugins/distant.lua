return {
  'chipsenkbeil/distant.nvim',
  branch = 'v0.3',
  lazy = true,
  keys = {
    {
      '<leader>dc',
      '<cmd>DistantConnect<CR>',
      desc = 'Distant: connect to remote'
    }
  },
  config = function()
    require('distant'):setup(
      {
        bin = 'distant'
      }
    )
  end
}
