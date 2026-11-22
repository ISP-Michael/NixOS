-- Follow Noctalia's light/dark mode: flatwhite for light, flatblack for dark.
-- Noctalia rewrites settings.toml when SUPER+W changes the theme, so a
-- directory watcher catches the change without polling.
local M = {}

local settings_dir = vim.fn.expand('~/.local/state/noctalia')
local settings_file = settings_dir .. '/settings.toml'
local watcher = nil
local timer = nil

local function read_mode()
  local ok, lines = pcall(
    vim.fn.readfile,
    settings_file
  )
  if not ok then
    return nil
  end

  local in_theme = false
  for _, line in ipairs(lines) do
    if line:match('^%[theme%]%s*$') then
      in_theme = true
    elseif in_theme and line:match('^%[') then
      break
    elseif in_theme then
      local mode = line:match('^mode%s*=%s*"([^"]+)"')
      if mode then
        return mode
      end
    end
  end
  return nil
end

local function sync()
  local want = read_mode() == 'light' and 'flatwhite' or 'flatblack'
  if vim.g.colors_name ~= want then
    vim.cmd.colorscheme(want)
  end
end

local function schedule_sync()
  if timer then
    timer:stop()
  else
    timer = vim.uv.new_timer()
  end
  timer:start(
    80,
    0,
    vim.schedule_wrap(sync)
  )
end

function M.setup()
  sync()

  if watcher or vim.fn.isdirectory(settings_dir) == 0 then
    return
  end

  watcher = vim.uv.new_fs_event()
  watcher:start(
    settings_dir,
    {},
    vim.schedule_wrap(schedule_sync)
  )
end

return M
