-- Локальная цветовая схема: colors/flatblack.lua в этом же конфиге.
-- Тёмная пара к flatwhite (порт helix-темы flatwhite).
return {
  {
    name = 'flatblack',
    dir = vim.fn.stdpath('config'),
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = 'dark'
      vim.cmd.colorscheme('flatblack')
    end,
  },
}
