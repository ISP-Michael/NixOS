-- Native plugin manager for Neovim 0.13.
--
-- vim.pack installs plugins once; during init it only puts them on 'runtimepath'
-- (like :packadd!), so nothing from plugin/ is sourced.  Each plugin is then
-- loaded on first use by M.load(), which is plain :packadd -- no shim that
-- imitates lazy.nvim.
local M = {
  loaded = {},
  runtime_loaded = {},
  loaders = {},
}

local specs = {
  'https://github.com/CRAG666/code_runner.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/ibhagwan/fzf-lua',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/kdheepak/lazygit.nvim',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/karb94/neoscroll.nvim',
  {
    src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
    version = 'v3.x',
  },
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/windwp/nvim-autopairs',
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
  'https://github.com/kndndrj/nvim-dbee',
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/nvim-pack/nvim-spectre',
  'https://github.com/kylechui/nvim-surround',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  'https://github.com/windwp/nvim-ts-autotag',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/folke/snacks.nvim',
  'https://github.com/akinsho/toggleterm.nvim',
  'https://github.com/xiyaowong/transparent.nvim',
  'https://github.com/folke/trouble.nvim',
  'https://github.com/junegunn/vim-easy-align',
  'https://github.com/LnL7/vim-nix',
  'https://github.com/Wansmer/langmapper.nvim',
}

function M.setup()
  -- A callable `load` makes vim.pack install/register the plugin without
  -- touching 'runtimepath'.  With the boolean false it calls :packadd!, and
  -- Neovim's normal startup then sources every plugin/ file from rtp -- which
  -- is exactly the eager loading we are avoiding.  M.load() calls :packadd
  -- for the one plugin that is needed.
  local ok, err = pcall(
    vim.pack.add,
    specs,
    {
      load = function() end,
      confirm = false,
    }
  )
  if not ok then
    vim.notify(
      ('vim.pack: %s'):format(err),
      vim.log.levels.ERROR
    )
  end
end

--- Load plugin/ and ftdetect/ scripts once.
---@param name string
function M.load(name)
  if M.loaded[name] then
    return
  end
  local ok, err = pcall(
    vim.cmd.packadd,
    name
  )
  if not ok then
    error(('packadd %s failed: %s'):format(name, err))
  end
  M.loaded[name] = true
end

--- Add plugin files (queries, parser, lsp/, syntax/) to 'runtimepath' without
--- sourcing plugin/.  Safe after startup: Neovim's automatic rtp plugin pass
--- has already happened.
---@param name string
function M.runtime(name)
  if M.runtime_loaded[name] then
    return
  end
  local ok, err = pcall(
    vim.cmd.packadd,
    {
      name,
      bang = true,
    }
  )
  if not ok then
    error(('packadd! %s failed: %s'):format(name, err))
  end
  M.runtime_loaded[name] = true
end

--- Load and configure a plugin through its registered loader.
---@param name string
function M.use(name)
  if M.loaded[name] then
    return
  end
  local fn = M.loaders[name]
  if fn then
    fn()
  else
    M.load(name)
  end
end

--- Register a plugin setup used by both the lazy trigger and the benchmark.
---@param name string
---@param fn fun()
function M.register(name, fn)
  M.loaders[name] = fn
end

--- Load and configure every plugin.  Used by the speed benchmark and by
--- :PackLoadAll.
function M.load_all()
  for name, fn in pairs(M.loaders) do
    if not M.loaded[name] then
      local ok, err = pcall(fn)
      if not ok then
        vim.notify(
          ('plugin %s: %s'):format(name, err),
          vim.log.levels.ERROR
        )
      end
    end
  end
end

vim.api.nvim_create_user_command(
  'PackLoadAll',
  function()
    M.load_all()
  end,
  {
    desc = 'Load and configure every vim.pack plugin',
  }
)

return M
