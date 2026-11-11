-- EasyAlign exposes <Plug>(EasyAlign).  Adding its runtime path during init is
-- enough: Neovim's normal startup sources this one small plugin file once, and
-- the mapping can stay a plain <Plug> map.  Calling P.load() here would source
-- the same file twice (once now, once in the startup rtp pass).
local P = require('pack')

P.runtime('vim-easy-align')

vim.keymap.set(
  {
    'n',
    'v'
  },
  'ga',
  '<Plug>(EasyAlign)',
  {
    desc = 'EasyAlign'
  }
)

return {}
