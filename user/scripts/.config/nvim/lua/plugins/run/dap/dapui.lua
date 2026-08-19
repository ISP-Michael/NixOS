return  {
  'rcarriga/nvim-dap-ui',
  dependencies = {
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio'
  },
  config = function()
    require('dapui').setup()
    local dap, dapui = require('dap'), require('dapui')
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.after.event_terminated['dapui_config'] = dapui.close
    dap.listeners.after.event_exited['dapui_config'] = dapui.close
  end
}
