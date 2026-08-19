return {
  'neovim/nvim-lspconfig',
  lazy = false,
  config = function()
    vim.lsp.config(
      'lua_ls',
      {
        settings = {
          Lua = {
            diagnostics = {
              globals = {
                'vim',
                'hl'
              }
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            }
          }
        }
      }
    )
    vim.lsp.config(
      'ruff',
      {
        init_options = {
          settings = {
            hover = {
              enabled = false
            }
          }
        }
      }
    )
    local lsp_servers = {
      'ty',
      'ruff',
      'csharp_ls',
      'nixd',
      'clangd',
      'lua_ls',
      'emmet_ls',
      'gopls',
    }
    for _, server in ipairs(lsp_servers) do
      vim.lsp.enable(server)
    end
    vim.api.nvim_create_autocmd(
      'BufWritePre',
      {
        pattern = {
          '*.py',
          '*.go',
        },
        callback = function(args)
          vim.lsp.buf.code_action(
            {
              context = {
                only = {
                  'source.organizeImports'
                },
                diagnostics = {

                },
              },
              apply = true
            }
          )
          vim.lsp.buf.format(
            {
              bufnr = args.buf
            }
          )
        end
      }
    )
    vim.keymap.set(
      'i',
      '<C-Space>',
      '<C-x><C-o>'
    )
    vim.keymap.set(
      'n',
      '<leader>e',
      vim.diagnostic.open_float
    )
    vim.api.nvim_create_autocmd(
      'LspAttach',
      {
        callback = function(ev)
          vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
        end
      }
    )
  end
}
