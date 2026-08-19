local option = vim.opt
option.mouse = 'a'
option.tabstop = 4
option.wrap = false
option.number = true
option.shiftwidth = 4
option.undofile = true
option.smarttab = true
option.softtabstop = 4
option.showmode = false
option.swapfile = false
option.expandtab = true
option.ignorecase = true
option.autoindent = true
option.cursorline = true
option.relativenumber = true
option.clipboard = 'unnamedplus'
local undodir = vim.fn.stdpath('cache') .. '/undo'
vim.fn.mkdir(undodir, 'p')
option.undodir = undodir
option.signcolumn = 'yes:1'
option.smoothscroll = true
option.fillchars = { eob = ' ' }
option.completeopt = { 'menu', 'menuone', 'noselect', 'noinsert' }

vim.g.mapleader = ' '
vim.g.maplocalleader = ','
