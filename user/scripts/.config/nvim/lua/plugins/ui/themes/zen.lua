return {
  'nendix/zen.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('zen').setup(
      {
        variant = 'dark',
        keywordStyle = {
          italic = false,
        },
        commentStyle = {
          italic = false
        },
        functionStyle = {
          bold = true,
        },
      }
    )
  end
}
