local P = require('pack')

P.register(
  'nvim-treesitter',
  function()
    P.runtime('nvim-treesitter')
  end
)

require('core.treesitter')

-- Runtime files are enough for highlighting, so plugin/nvim-treesitter.lua is
-- not sourced at startup.  Parser management still needs its commands; load
-- the plugin on first :TS* use.
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
