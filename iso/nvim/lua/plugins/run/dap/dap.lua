return {
  'mfussenegger/nvim-dap',
  event = 'VeryLazy',
  config = function()
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
        pythonPath = function() return 'python3' end
      }
    }
    local set = vim.keymap.set
    set('n', '<leader>c',  dap.continue)
    set('n', '<leader>tb', dap.toggle_breakpoint)
    set('n', '<leader>so', dap.step_over)
    set('n', '<leader>si', dap.step_into)
  end
}
