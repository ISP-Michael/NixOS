return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    config = function()
      local langs = {
        'bash',
        'http',
        'python',
        'javascript',
        'dockerfile',
        'yaml',
        'nix',
        'qmljs',
      }
      require('nvim-treesitter').install(langs)
      vim.api.nvim_create_autocmd(
        'FileType',
        {
          pattern = langs,
          callback = function()
            vim.treesitter.start()
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
          end
        }
      )
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    },
    config = function()
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
    end,
  },
}
