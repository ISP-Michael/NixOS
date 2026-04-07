return {
  'lewis6991/gitsigns.nvim',
  lazy = false,
  priority = 600,
  config = function()
    require('gitsigns').setup({
      signs = {
        changedelete = { text = '─' },
      },
      signs_staged = {
        changedelete = { text = '─' }
      },
      on_attach = function(bufnr)
        local set = vim.keymap.set
        set(
          'n',
          ']c',
          function()
            require('gitsigns').next_hunk()
          end,
          {buffer = bufnr}
        )
        set(
          'n',
          '[c',
          function()
            require('gitsigns').prev_hunk()
          end,
          {buffer = bufnr}
        )
      end
    })
  end
}
