-- Локальная цветовая схема: colors/flatwhite.lua в этом же конфиге.
-- Портируем helix-тему flatwhite (runtime/themes/flatwhite.toml).
return {
  {
    name = 'flatwhite',
    dir = vim.fn.stdpath('config'),
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = 'light'
      vim.cmd.colorscheme('flatwhite')
    end,
  },
}
