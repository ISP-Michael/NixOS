local P = require('pack')

P.register(
  'nvim-treesitter',
  function()
    P.load('nvim-treesitter')
  end
)

require('core.treesitter')

-- The plugin itself is loaded on the first matching file.  Parser management
-- still needs :TS* commands before any tree-sitter file is open; the wrappers
-- load the plugin and then hand over to its real commands.
local function ts_command(name)
  return function(args)
    P.load('nvim-treesitter')
    local cmd = name
    if args.bang then
      cmd = cmd .. '!'
    end
    if args.args ~= '' then
      cmd = cmd .. ' ' .. args.args
    end
    vim.cmd(cmd)
  end
end

for _, name in ipairs(
  {
    'TSInstall',
    'TSInstallFromGrammar',
    'TSUpdate',
    'TSUninstall',
    'TSLog',
  }
) do
  vim.api.nvim_create_user_command(
    name,
    ts_command(name),
    {
      nargs = '*',
      bang = true,
      desc = 'tree-sitter: ' .. name,
    }
  )
end

return {}
