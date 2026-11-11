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
            runtime = {
              version = 'LuaJIT'
            },
            diagnostics = {
              globals = {
                'vim',
                'hl'
              }
            },
            workspace = {
              -- Only the Neovim runtime, not every directory from 'runtimepath'.
              -- The full list makes lua_ls index every installed plugin.
              library = {
                vim.env.VIMRUNTIME
              },
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
    vim.lsp.config(
      'nixd',
      {
        cmd = {
          'nixd',
          '--log=error'
        },
        settings = {
          nixd = {
            formatting = {
              command = {
                'alejandra'
              }
            },
            options = {
              nixpkgs = {
                expr = 'import <nixpkgs> {}'
              }
            }
          }
        }
      }
    )
    local function truncate(text, max)
      if not text or text == '' then
        return text
      end
      if vim.fn.strchars(text) <= max then
        return text
      end
      return vim.fn.strcharpart(text, 0, max - 3) .. '...'
    end

    local function completion_convert(item)
      local label = item.label or ''
      local label_detail = vim.tbl_get(item, 'labelDetails', 'detail') or ''
      local menu = vim.tbl_get(item, 'labelDetails', 'description') or item.detail or ''
      return {
        abbr = truncate(label .. label_detail, 55),
        menu = truncate(menu, 35),
      }
    end

    local lsp_servers = {
      'ty',
      'ruff',
      'nixd',
      'clangd',
      'gopls',
      'lua_ls',
      'rust_analyzer',
      'ts_ls',
      'csharp_ls',
      'emmet_language_server',
      'superhtml',
      'bashls',
      'yamlls',
      'sqls',
    }
    for _, server in ipairs(lsp_servers) do
      vim.lsp.enable(server)
    end
    vim.keymap.set(
      'i',
      '<C-l>',
      function()
        if vim.fn.pumvisible() == 1 then
          -- Keep the built-in popup action: add one character from the match.
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<C-l>', true, false, true),
            'n',
            false
          )
          return
        end
        vim.lsp.completion.get()
      end,
      {
        desc = 'LSP: completion'
      }
    )
    vim.keymap.set(
      'n',
      '<leader>e',
      vim.diagnostic.open_float,
      {
        desc = 'Diagnostic: show float'
      }
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
            vim.lsp.completion.enable(
              true,
              ev.data.client_id,
              ev.buf,
              {
                autotrigger = false,
                convert = completion_convert
              }
            )
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
