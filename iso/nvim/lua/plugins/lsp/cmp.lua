return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'rafamadriz/friendly-snippets',
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make install_jsregexp',
      },
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local ls = require("luasnip")
      cmp.setup({
        completion = {
          autocomplete = false
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if ls.expandable() or ls.expand_or_jumpable() then
              ls.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if ls.jumpable(-1) then
              ls.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<C-f>'] = cmp.mapping.select_next_item(),
          ['<C-b>'] = cmp.mapping.select_prev_item()
        }),
        sources = cmp.config.sources(
          {
            { name = 'nvim_lsp' },
            { name = 'path' },
            { name = 'luasnip' }
          }
        )
      })
    end
  }
}
