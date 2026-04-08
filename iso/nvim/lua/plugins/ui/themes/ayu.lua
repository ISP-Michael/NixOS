vim.g.loaded_matchparen = 1

return {
  'Shatur/neovim-ayu',
  lazy = false,
  priority = 1000,
  config = function()
    local ayu = require('ayu')

    local colors = {
      white = "#FFFFFF",
      gray  = "#CCCAC2",
      muted = "#8A95A7",
      blue  = "#73A3C7",
      pink  = "#D4BFFF",
      green = "#BAE67E",
      bg    = "#111111",
      noise = "#47525E"
    }

    ayu.setup({
      mirage = true,
      overrides = {
        -- Normal = { bg = colors.bg },
        -- NormalFloat = { bg = "#0B0D12" },
        EndOfBuffer = { fg = colors.bg },

        Function = { fg = colors.white, bold = false },
        ["@function.call"] = { fg = colors.white },
        ["@method.call"] = { fg = colors.white },
        ["@punctuation.bracket"] = { fg = colors.white },

        Identifier = { fg = colors.gray },
        ["@variable"] = { fg = colors.gray },
        Operator = { fg = colors.gray },
        ["@operator"] = { fg = colors.gray },
        ["@punctuation.delimiter"] = { fg = colors.gray },

        Keyword = { fg = colors.muted },
        ["@keyword"] = { fg = colors.muted },

        String = { fg = colors.green, italic = false },
        Number = { fg = colors.pink },
        Boolean = { fg = colors.pink },
        Type = { fg = colors.blue },
        ["@type"] = { fg = colors.blue },
        ["@exception"] = { fg = colors.blue },

        ["@lsp.type.function"] = { fg = colors.white },
        ["@lsp.type.method"] = { fg = colors.white },
        ["@lsp.type.parameter"] = { fg = colors.gray },
        ["@lsp.type.variable"] = { fg = colors.gray },
        ["@lsp.type.property"] = { fg = colors.gray },
        ["@lsp.type.type"] = { fg = colors.blue },
        ["@lsp.type.class"] = { fg = colors.blue },
        ["@lsp.type.enum"] = { fg = colors.blue },
        ["@lsp.type.keyword"] = { fg = colors.muted },

        Comment = { fg = colors.noise, italic = true },

        -- IblIndent = { fg = "#1A1D23" },
        -- IblWhitespace = { fg = "#1A1D23" },
        -- MiniIndentscopeSymbol = { fg = "#3E4B59" },
      }
    })

    ayu.colorscheme()
  end
}
