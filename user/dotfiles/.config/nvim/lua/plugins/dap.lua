local P = require('pack')
local M = {}

local function dap()
  P.use('nvim-dap')
  return require('dap')
end

function M.continue()
  dap().continue()
end

function M.toggle_breakpoint()
  dap().toggle_breakpoint()
end

function M.step_over()
  dap().step_over()
end

function M.step_into()
  dap().step_into()
end

function M.terminate()
  if not P.loaded['nvim-dap'] then
    return
  end
  pcall(
    function()
      require('dap').terminate()
    end
  )
  pcall(
    function()
      require('dapui').close()
    end
  )
end

P.register(
  'nvim-dap',
  function()
    P.load('nvim-nio')
    P.load('nvim-dap')
    P.load('nvim-dap-ui')
    P.load('nvim-dap-virtual-text')

    local dap = require('dap')
    dap.adapters.python = {
      type = 'executable',
      command = 'python',
      args = {
        '-m',
        'debugpy.adapter'
      }
    }
    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        python = function()
          return 'python3'
        end
      }
    }

    require('dapui').setup()
    local dapui = require('dapui')
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.after.event_terminated['dapui_config'] = dapui.close
    dap.listeners.after.event_exited['dapui_config'] = dapui.close

    require('nvim-dap-virtual-text').setup()
  end
)

vim.keymap.set(
  'n',
  '<leader>c',
  M.continue,
  {
    desc = 'DAP: continue'
  }
)
vim.keymap.set(
  'n',
  '<leader>tb',
  M.toggle_breakpoint,
  {
    desc = 'DAP: toggle breakpoint'
  }
)
vim.keymap.set(
  'n',
  '<leader>so',
  M.step_over,
  {
    desc = 'DAP: step over'
  }
)
vim.keymap.set(
  'n',
  '<leader>si',
  M.step_into,
  {
    desc = 'DAP: step into'
  }
)

return M
