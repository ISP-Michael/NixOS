return {
  'nvim-pack/nvim-spectre',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  keys = {
    {
      '<leader>S',
      function()
        require('spectre').toggle()
      end,
      desc = 'Toggle Spectre (Search and Replace)'
    },
    {
      '<leader>sw',
      function()
        require('spectre').open_visual(
          {
            select_word = true
          }
        )
      end,
      desc = 'Search current word'
    }
  },
  config = function()
    require('spectre').setup(
      {
        is_live = true,
        open_cmd = 'vnew',
      }
    )
  end
}
