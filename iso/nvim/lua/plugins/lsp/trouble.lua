return {
  'folke/trouble.nvim',
  keys = {
    { '<leader>xx', ':Trouble diagnostics toggle<cr>' }
  },
  config = function()
    require('trouble').setup()
  end
}
