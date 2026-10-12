return {
  'neovim/nvim-lspconfig',
  lazy = false,
  config = function()
    vim.lsp.config(
      '*',
      {
        hover = {
          border = 'rounded',
          max_width = 100,
          max_height = 0.8,
          wrap = true
        },
        signatureHelp = {
          border = 'rounded',
          max_width = 100,
          max_height = 0.6,
          wrap = true
        }
      }
    )
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
      '<C-b>',
      function()
        vim.lsp.completion.get()
      end,
      {
        desc = 'LSP: completion'
      }
    )
    vim.keymap.set(
      'i',
      'K',
      function()
        vim.lsp.buf.signature_help()
      end,
      {
        desc = 'LSP: signature help'
      }
    )
    vim.keymap.set(
      'n',
      '<leader>e',
      vim.diagnostic.open_float
    )
    -- Signature help opens on its own: after picking an item from the list
    -- (CompleteDone) or right after typing '(' or ','.
    local sig_group = vim.api.nvim_create_augroup('LspSignatureHelp', { clear = true })
    vim.api.nvim_create_autocmd(
      'LspAttach',
      {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then
            return
          end
          -- ruff has no completion (completionProvider = false); without this
          -- check it still gets the request and throws an error on screen
          if client:supports_method('textDocument/completion', ev.buf) then
            vim.lsp.completion.enable(true, ev.data.client_id, ev.buf)
          end
          if not client:supports_method('textDocument/signatureHelp', ev.buf) then
            return
          end
          vim.api.nvim_clear_autocmds(
            {
              group = sig_group,
              buffer = ev.buf
            }
          )
          vim.api.nvim_create_autocmd(
            'CompleteDone',
            {
              group = sig_group,
              buffer = ev.buf,
              callback = function()
                vim.lsp.buf.signature_help({ silent = true })
              end
            }
          )
          vim.api.nvim_create_autocmd(
            'TextChangedI',
            {
              group = sig_group,
              buffer = ev.buf,
              callback = function()
                local line = vim.api.nvim_get_current_line()
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local before = line:sub(col, col)
                if before == '(' or before == ',' then
                  vim.lsp.buf.signature_help({ silent = true })
                end
              end
            }
          )
        end
      }
    )
  end
}
