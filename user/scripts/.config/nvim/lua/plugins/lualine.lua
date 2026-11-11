local P = require('pack')
local M = {}

-- U+E0B4 / U+E0B6 (nvim-web-devicons powerline separators).
local left_sep = '\238\130\180'
local right_sep = '\238\130\182'

local function setup()
  P.load('lualine.nvim')
  require('lualine').setup(
    {
      options = {
        theme = 'auto',
        icons_enabled = false,
        component_separators = '│',
        section_separators = {
          left = left_sep,
          right = right_sep
        }
      },
      sections = {
        lualine_a = {
          {
            'mode',
            separator = {
              left = right_sep,
              right = left_sep
            },
            right_padding = 2
          }
        },
        lualine_b = {
          'filename',
          'branch'
        },
        lualine_c = {
          'fileformat'
        },
        lualine_x = {

        },
        lualine_y = {
          'filetype',
          'progress'
        },
        lualine_z = {
          {
            'location',
            separator = {
              left = right_sep,
              right = left_sep
            },
            left_padding = 2
          }
        }
      },
      inactive_sections = {
        lualine_a = {
          'filename'
        },
        lualine_b = {

        },
        lualine_c = {

        },
        lualine_x = {

        },
        lualine_y = {

        },
        lualine_z = {
          'location'
        }
      },
      tabline = {

      },
      extensions = {

      }
    }
  )
end

M.setup = setup
P.register('lualine.nvim', setup)

return M
