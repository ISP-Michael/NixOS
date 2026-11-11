-- Built-in tree-sitter highlighting plus text objects.  Parsers and queries
-- live in the nvim-treesitter directory, but nothing from the plugin is needed
-- until a matching buffer is opened.  Text-object mappings are installed as
-- stubs and load nvim-treesitter-textobjects on the first real use.
local P = require('pack')

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

local aliases = {
  bash = {
    'sh',
  },
  javascript = {
    'js',
  },
  json = {
    'jsonc',
  },
  python = {
    'py',
  },
  qmljs = {
    'qml',
  },
  typescript = {
    'ts',
  },
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

local aliases_ready = false
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

local function ensure_textobjects()
  if textobjects_ready then
    return true
  end
  local ok, err = pcall(setup_textobjects)
  if not ok then
    vim.notify(
      ('nvim-treesitter-textobjects: %s'):format(err),
      vim.log.levels.WARN
    )
    return false
  end
  return true
end

-- Stubs are overwritten by setup_textobjects() above.  Until then they call
-- the same select/move functions the real mappings use, so operator-pending
-- commands like `daf` keep working; feeding the key back would lose the
-- pending operator.
local function select_stub(query)
  return function()
    if ensure_textobjects() then
      require('nvim-treesitter-textobjects.select').select_textobject(query)
    end
  end
end

local function move_stub(query, direction)
  return function()
    if ensure_textobjects() then
      local move = require('nvim-treesitter-textobjects.move')
      if direction == 'next' then
        move.goto_next_start(query)
      else
        move.goto_previous_start(query)
      end
    end
  end
end

for key, query in pairs(objects) do
  local inner_query = inner_objects[key] or query:gsub('outer', 'inner')
  vim.keymap.set(
    {
      'x',
      'o'
    },
    'a' .. key,
    select_stub(query)
  )
  vim.keymap.set(
    {
      'x',
      'o'
    },
    'i' .. key,
    select_stub(inner_query)
  )
  vim.keymap.set(
    {
      'n',
      'x',
      'o'
    },
    ']' .. key,
    move_stub(query, 'next')
  )
  vim.keymap.set(
    {
      'n',
      'x',
      'o'
    },
    '[' .. key,
    move_stub(query, 'prev')
  )
end

vim.api.nvim_create_autocmd(
  'FileType',
  {
    pattern = langs,
    callback = function(args)
      P.runtime('nvim-treesitter')
      if not aliases_ready then
        aliases_ready = true
        for lang, filetypes in pairs(aliases) do
          for _, ft in ipairs(filetypes) do
            vim.treesitter.language.register(lang, ft)
          end
        end
      end
      pcall(vim.treesitter.start, args.buf)
      local bad_maps = {
        '[m',
        ']m',
        '[M',
        ']M',
        '[[',
        ']]'
      }
      for _, map in ipairs(bad_maps) do
        pcall(
          vim.keymap.del,
          'n',
          map,
          {
            buffer = true
          }
        )
      end
    end,
  }
)

P.register('nvim-treesitter-textobjects', setup_textobjects)

return {
  setup_textobjects = setup_textobjects,
}
