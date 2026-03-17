return {
  'nickjvandyke/opencode.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
  },
  keys = {
    {
      '<leader>oa',
      function()
        require('opencode').ask()
      end,
      desc = 'AI: Ask',
      mode = { 'n', 'v' }
    },
    {
      '<leader>ot',
      function()
        require('opencode').toggle()
      end,
      desc = 'AI: Terminal'
    },
    {
      '<leader>os',
      function()
        require('opencode').select()
      end,
      desc = 'AI: Actions',
      mode = { 'n', 'v' }
    },
  },
  config = function()
    require('opencode')
  end,
}
