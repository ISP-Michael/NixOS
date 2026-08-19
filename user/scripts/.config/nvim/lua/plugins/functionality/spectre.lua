return {
  'nvim-pack/nvim-spectre',
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require('spectre').setup(
      {
        is_live = true,
        open_cmd = 'vnew',
      }
    )
    vim.keymap.set(
      'n',
      '<leader>S',
      '<cmd>lua require("spectre").toggle()<CR>',
      {
        desc = 'Toggle Spectre (Search and Replace)'
      }
    )
    vim.keymap.set(
      'n',
      '<leader>sw',
      function()
        require('spectre').open_visual(
          {
            select_word = true
          }
        )
      end,
      {
        desc = 'Search current word'
      }
    )
  end
}
