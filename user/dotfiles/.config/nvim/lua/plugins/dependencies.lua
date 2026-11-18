-- Dependencies have no setup of their own; the loaders make them explicit for
-- :PackLoadAll and for the full-plugin benchmark.
local P = require('pack')

for _, name in ipairs(
  {
    'plenary.nvim',
    'nui.nvim',
    'nvim-nio',
    'nvim-web-devicons',
  }
) do
  P.register(
    name,
    function()
      P.load(name)
    end
  )
end

return {}
