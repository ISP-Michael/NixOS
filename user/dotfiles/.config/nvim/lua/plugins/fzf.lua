local P = require('pack')
local M = {}

local function fzf()
  P.use('fzf-lua')
  return require('fzf-lua')
end

function M.files()
  fzf().files(
    {
      cwd = require('core.project').root(),
    }
  )
end

function M.oldfiles()
  fzf().oldfiles()
end

function M.grep()
  fzf().grep(
    {
      cwd = require('core.project').root(),
    }
  )
end

function M.buffers()
  fzf().buffers()
end

-- Delete selected buffers and keep the picker open.  If the current buffer is
-- deleted, Neovim picks the alternate buffer; move the original window to the
-- next surviving buffer instead, matching `:bnext`.
local function delete_buffers(selected, opts)
  local path = require('fzf-lua.path')
  local ctx = opts.__CTX or require('fzf-lua.utils').__CTX()
  local current = ctx and ctx.bufnr or vim.api.nvim_get_current_buf()
  local deleting = {}
  for _, sel in ipairs(selected) do
    local entry = path.entry_to_file(sel, opts)
    if entry and entry.bufnr then
      deleting[entry.bufnr] = true
    end
  end

  require('fzf-lua').actions.buf_del(selected, opts)

  if not deleting[current]
      or vim.api.nvim_buf_is_valid(current)
      or not ctx
      or not ctx.winid
      or not vim.api.nvim_win_is_valid(ctx.winid)
  then
    return
  end

  local all = ctx.buflist or vim.api.nvim_list_bufs()
  if #all == 0 then
    return
  end
  local start = 1
  for i, bufnr in ipairs(all) do
    if bufnr == current then
      start = i + 1
      break
    end
  end
  for i = 0, #all - 1 do
    local bufnr = all[(start + i - 1) % #all + 1]
    if bufnr ~= current
        and vim.api.nvim_buf_is_valid(bufnr)
        and vim.fn.buflisted(bufnr) == 1
        and not deleting[bufnr]
    then
      pcall(vim.api.nvim_win_set_buf, ctx.winid, bufnr)
      return
    end
  end
end

P.register(
  'fzf-lua',
  function()
    P.load('nvim-web-devicons')
    P.load('fzf-lua')
    require('fzf-lua').setup(
      {
        winopts = {
          height = 0.90,
          width = 0.90,
          row = 0.50,
          preview = {
            layout = 'horizontal',
            horizontal = 'right:50%',
          },
        },
        files = {
          previewer = false,
          file_icons = true,
        },
        oldfiles = {
          previewer = false,
          file_icons = true,
        },
        buffers = {
          previewer = false,
          file_icons = true,
          sort_lastused = true,
          ignore_current_buffer = false,
          _headers = {},
          header = ' tab/shift-tab select · ctrl-a all · ctrl-d none · ctrl-x delete ',
          -- Keep the current buffer in the list as a normal selectable item.
          -- The default header line makes it impossible to close from here.
          fzf_opts = {
            ['--header-lines'] = false,
          },
          keymap = {
            fzf = {
              ['ctrl-a'] = 'select-all',
              ['ctrl-d'] = 'deselect-all',
              ['ctrl-space'] = 'toggle+down',
            },
          },
          -- Delete selected buffers and reload the list in place, so the
          -- picker stays open for more deletions and navigation.
          actions = {
            ['ctrl-x'] = {
              fn = delete_buffers,
              reload = true,
            },
          },
        },
        lsp = {
          file_icons = true,
          icons = true,
        },
        grep = {
          file_icons = true,
          previewer = false,
        },
      }
    )
  end
)

vim.keymap.set(
  'n',
  '<leader>ff',
  M.files,
  {
    desc = 'Files (fzf)'
  }
)
vim.keymap.set(
  'n',
  '<leader>fo',
  M.oldfiles,
  {
    desc = 'Recent files (fzf)'
  }
)
vim.keymap.set(
  'n',
  '<leader>fb',
  M.buffers,
  {
    desc = 'Buffers (fzf)'
  }
)
vim.keymap.set(
  'n',
  '<leader>fg',
  M.grep,
  {
    desc = 'Grep project (fzf)'
  }
)

return M
