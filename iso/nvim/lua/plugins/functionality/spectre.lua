return {
  'MagicDuck/grug-far.nvim',
  keys = {
    { '<leader>fr', ':GrugFar<cr>' }
  },
  config = function()
    require('grug-far').setup()
  end
}
