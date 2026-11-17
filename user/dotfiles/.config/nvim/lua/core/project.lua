-- Project root for Neovide.
--
-- Terminal Neovim keeps the shell's cwd as the project root.  Neovide is
-- launched from rofi, so its cwd is whatever the launcher happened to use;
-- autochdir then followed every opened file.  This module gives Neovide one
-- explicit project root and keeps fzf-lua anchored to it.
local M = {}

local markers = {
  '.git',
  'flake.nix',
  'Cargo.toml',
  'package.json',
  'pyproject.toml',
  'go.mod',
  'Makefile',
  'CMakeLists.txt',
  'compile_commands.json',
}

local state_file = vim.fn.stdpath('state') .. '/project-root'

local function valid(dir)
  return type(dir) == 'string' and dir ~= '' and vim.fn.isdirectory(dir) == 1
end

---@param path string
---@return string|nil
function M.detect(path)
  path = vim.fs.normalize(vim.fn.expand(path))
  if path == '' then
    return nil
  end
  if vim.fn.isdirectory(path) == 1 then
    return path
  end
  local root = vim.fs.root(path, markers)
  if root then
    return root
  end
  local dir = vim.fs.dirname(path)
  return valid(dir) and dir or nil
end

---@return string|nil
function M.saved()
  if vim.fn.filereadable(state_file) == 0 then
    return nil
  end
  local lines = vim.fn.readfile(state_file)
  local dir = lines[1]
  return valid(dir) and dir or nil
end

---@param dir string
---@param opts? {notify?: boolean}
---@return boolean
function M.set(dir, opts)
  dir = vim.fs.normalize(vim.fn.expand(dir))
  if not valid(dir) then
    vim.notify(
      ('Project directory does not exist: %s'):format(dir),
      vim.log.levels.WARN
    )
    return false
  end

  vim.g.project_root = dir
  vim.api.nvim_set_current_dir(dir)
  vim.fn.mkdir(vim.fn.stdpath('state'), 'p')
  vim.fn.writefile({ dir }, state_file)
  if not opts or opts.notify ~= false then
    vim.notify(
      ('Project: %s'):format(dir),
      vim.log.levels.INFO
    )
  end
  return true
end

---@return string
function M.root()
  if valid(vim.g.project_root) then
    return vim.g.project_root
  end
  if vim.g.neovide then
    local name = vim.api.nvim_buf_get_name(0)
    if name ~= '' then
      local dir = M.detect(name)
      if valid(dir) then
        return dir
      end
    end
  end
  -- Terminal Neovim: keep the shell cwd, but if it is deep inside a project,
  -- anchor fzf at the project root instead of the current subdirectory.
  local cwd = vim.fn.getcwd()
  return vim.fs.root(cwd, markers) or cwd
end

local function input_select(start)
  vim.ui.input(
    {
      prompt = 'Project directory: ',
      default = start,
      completion = 'dir',
    },
    function(input)
      if input and input ~= '' then
        M.set(input)
      end
    end
  )
end

--- Pick a project directory.  In Neovide use KDE's native folder dialog;
--- fall back to the command line picker when it is unavailable.
function M.select()
  local start = M.root()
  if start == vim.fn.expand('~') or start == '/' then
    local projects = vim.fn.expand('~/Data/Projects')
    if valid(projects) then
      start = projects
    end
  end
  if vim.g.neovide and vim.fn.executable('kdialog') == 1 then
    vim.system(
      {
        'kdialog',
        '--title',
        'Neovide: project directory',
        '--getexistingdirectory',
        start,
      },
      {
        text = true,
      },
      function(obj)
        vim.schedule(
          function()
            if obj.code == 0 then
              local dir = vim.trim(obj.stdout or '')
              if dir ~= '' then
                M.set(dir)
              end
            end
          end
        )
      end
    )
  else
    input_select(start)
  end
end

local function on_start()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= '' and M.detect(name) or nil

  if not dir and vim.fn.argc() > 0 then
    local arg = vim.fn.fnamemodify(vim.fn.argv(0), ':p')
    if vim.fn.isdirectory(arg) == 1 then
      dir = arg
    end
  end

  if not dir then
    dir = M.saved()
  end

  if dir and M.set(dir, { notify = false }) then
    return
  end

  -- First Neovide launch without a file and without a saved project: ask
  -- once.  Later launches silently reuse the saved root.
  if vim.fn.argc() == 0 then
    M.select()
  end
end

function M.setup()
  vim.api.nvim_create_user_command(
    'ProjectRoot',
    function(args)
      if args.args ~= '' then
        M.set(args.args)
      else
        M.select()
      end
    end,
    {
      nargs = '?',
      complete = 'dir',
      desc = 'Choose the project directory used by fzf',
    }
  )

  vim.keymap.set(
    'n',
    '<leader>pp',
    function()
      M.select()
    end,
    {
      desc = 'Project directory',
    }
  )

  if not vim.g.neovide then
    return
  end

  vim.api.nvim_create_autocmd(
    'VimEnter',
    {
      once = true,
      callback = function()
        vim.schedule(on_start)
      end,
    }
  )
end

return M
