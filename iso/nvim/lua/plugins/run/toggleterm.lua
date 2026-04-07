return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup({
      autochdir = false
    })
  end,
  keys = {
    { '<leader>tt', function() require('toggleterm').toggle() end }
  }
}
