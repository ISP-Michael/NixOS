return {
  'nvim-treesitter/nvim-treesitter-context',
  lazy = false,
  priority = 950,
  config = function()
    require('treesitter-context').setup(
      {
        enable = true,
        max_lines = 1,
        mode = 'cursor'
      }
    )
  end
}
