-- snacks.nvim is only used for its notifier.  Load it on the first message
-- instead of paying for the whole module at startup.
local P = require('pack')

P.register(
  'snacks.nvim',
  function()
    P.load('snacks.nvim')
    require('snacks').setup(
      {
        notifier = {
          enabled = true,
          timeout = 3000,
        },
      }
    )
  end
)

local original = vim.notify
local loading = false
local wrapper

wrapper = function(msg, level, opts)
  if loading then
    return original(msg, level, opts)
  end
  if not P.loaded['snacks.nvim'] then
    loading = true
    local ok = pcall(P.use, 'snacks.nvim')
    loading = false
    if not ok then
      vim.notify = original
      return original(msg, level, opts)
    end
  end
  local notify = vim.notify
  if notify == wrapper then
    notify = original
  end
  return notify(msg, level, opts)
end

vim.notify = wrapper

return {}
