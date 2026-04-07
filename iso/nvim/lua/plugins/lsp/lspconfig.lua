return {
  'neovim/nvim-lspconfig',
  lazy = false,
  priority = 900,
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = { diagnostics = { globals = { 'vim' } } }
      }
    })

    local lsp_servers = {
      'ruff',
      'ty',
      'csharp_ls',
      'nixd',
      'clangd',
      'lua_ls',
      'emmet_ls',
      'gopls'
    }

    for _, server in ipairs(lsp_servers) do
      vim.lsp.enable(server)
    end

    vim.lsp.config('ruff', {
      init_options = {
        settings = {
          hover = {
            enabled = false
          }
        }
      }
    })

    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*.py',
      callback = function()
        vim.lsp.buf.code_action({
          context = { only = { 'source.organizeImports' } },
          apply = true
        })
        vim.defer_fn(function()
          vim.lsp.buf.format({ name = 'ruff' })
        end, 50)
      end
    })

    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = '*.go',
      callback = function()
        vim.lsp.buf.code_action(
          {
            context = {
              only = {
                'source.organizeImports'
              }
            },
            apply = true
          }
        )
        vim.lsp.buf.format(
          {
            async = false
          }
        )
      end
    })
  end
}
