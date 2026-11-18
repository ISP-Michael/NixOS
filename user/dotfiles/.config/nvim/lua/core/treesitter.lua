-- Built-in tree-sitter highlighting plus text objects.  Parsers and queries
-- live in the nvim-treesitter directory; the plugin is loaded on the first
-- matching file, once per session.
local P = require('pack')

-- Nix: nvim-treesitter injects bash/python/... into indented strings. A
-- multi-line string should stay a string, so drop all Nix injections.
vim.treesitter.query.set('nix', 'injections', '')

local langs = {
  'bash',
  'c',
  'cpp',
  'http',
  'javascript',
  'json',
  'jsonc',
  'lua',
  'markdown',
  'python',
  'qml',
  'sh',
  'toml',
  'dockerfile',
  'typescript',
  'yaml',
  'nix',
  'rust',
}

local objects = {
  ['f'] = '@function.outer',
  ['c'] = '@class.outer',
  ['l'] = '@loop.outer',
  ['i'] = '@conditional.outer',
  ['a'] = '@param.outer',
  ['k'] = '@call.outer',
  ['r'] = '@return.outer',
  ['x'] = '@conditional.condition.outer',
}
local inner_objects = {
  ['i'] = '@conditional.body.outer',
}

local textobjects_ready = false

local function setup_textobjects()
  if textobjects_ready then
    return
  end

  P.load('nvim-treesitter-textobjects')
  require('nvim-treesitter-textobjects').setup(
    {
      select = {
        enable = true,
        lookahead = true
      },
      move = {
        enable = true,
        set_jumps = true
      },
    }
  )
  local ts_select = require('nvim-treesitter-textobjects.select')
  local ts_move = require('nvim-treesitter-textobjects.move')
  for key, query in pairs(objects) do
    local inner_query = inner_objects[key] or query:gsub('outer', 'inner')
    vim.keymap.set(
      {
        'x',
        'o'
      },
      'a' .. key,
      function()
        ts_select.select_textobject(query)
      end
    )
    vim.keymap.set(
      {
        'x',
        'o'
      },
      'i' .. key,
      function()
        ts_select.select_textobject(inner_query)
      end
    )
    vim.keymap.set(
      {
        'n',
        'x',
        'o'
      },
      ']' .. key,
      function()
        ts_move.goto_next_start(query)
      end
    )
    vim.keymap.set(
      {
        'n',
        'x',
        'o'
      },
      '[' .. key,
      function()
        ts_move.goto_previous_start(query)
      end
    )
  end
  textobjects_ready = true
end

vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = langs,
    callback = function(args)
      -- Also registers the filetype aliases (sh -> bash, jsonc -> json,
      -- qml -> qmljs, ts -> typescript) and the :TS* commands.
      P.load('nvim-treesitter')
      pcall(vim.treesitter.start, args.buf)
      setup_textobjects()
    end,
  }
)

P.register('nvim-treesitter-textobjects', setup_textobjects)
