vim.api.nvim_create_autocmd({'FileType'}, {
  pattern = {
    'c',
    'cp',
    'cpp',
    'cs',
    'css',
    'elixir',
    'dart',
    'haskell',
    'html',
    'htmldjango',
    'hyprlang',
    'rust',
    'json',
    'jsonc',
    'javascript',
    'typescript',
    'lua',
    'nix',
    'markdown',
    'scss',
    'vim',
    'qml',
    'toml',
    'dosini'
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end
})

vim.api.nvim_create_autocmd({'FileType'}, {
	pattern = {
		'go'
	},
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
		vim.opt_local.expandtab = false
	end
}
)
