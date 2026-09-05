local themes = {
  {
    name = 'tokyonight',
    colorscheme = 'tokyonight'
  },
  {
    name = 'zen',
    colorscheme = 'zen'
  }
}

local M = {}

M.matches = function(theme)
  local current = vim.g.colors_name or ''
  if current == theme.colorscheme then
    return true
  end
  if current:find(theme.name, 1, true) then
    return true
  end
  return false
end

M.set = function(name)
  if name:find('tokyonight', 1, true) then
    vim.o.background = 'dark'
  end
  vim.cmd.colorscheme(name)
  vim.schedule(function()
    if package.loaded.lualine then
      require('lualine').refresh()
    end
    -- bufferline derives its palette once at setup and relies on the
    -- ColorScheme event to re-derive. Some compiled themes (zen) skip that
    -- event, so re-derive explicitly after the new scheme has applied.
    local ok, config = pcall(require, 'bufferline.config')
    if ok and config and config.update_highlights then
      local highlights = require('bufferline.highlights')
      highlights.reset_icon_hl_cache()
      highlights.set_all(config.update_highlights())
      vim.cmd('redrawstatus')
    end
  end)
end

M.next = function()
  local idx = 0
  for i, theme in ipairs(themes) do
    if M.matches(theme) then
      idx = i
      break
    end
  end
  local next_theme = themes[(idx % #themes) + 1]
  M.set(next_theme.colorscheme)
end

return M