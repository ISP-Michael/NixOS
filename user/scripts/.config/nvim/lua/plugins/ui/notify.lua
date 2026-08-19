return {
  'rcarriga/nvim-notify',
  lazy = false,
  priority = 100,
  config = function()
    require('notify').setup(
      {
        fps = 60,
        level = vim.log.levels.INFO,
        stages = 'fade',
        render = 'minimal'
      }
    )
    vim.notify = require('notify')
  end
}
