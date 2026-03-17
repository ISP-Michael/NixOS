return {
  'CRAG666/code_runner.nvim',
  dependencies = {
    'akinsho/toggleterm.nvim'
  },
  keys = {
    { '<leader>rc', ':RunCode<cr>', mode = { 'v', 'n' } }
  },
  config = function()
    require('code_runner').setup({
      filetype = {
        python = 'python3 -u',
        javascript = 'node',
        typescript = 'node',
        rust = 'cargo run',
        cpp = 'g++ $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt',
        cs = 'dotnet run',
        go = 'go run'
      },
      mode = 'toggleterm'
    })
  end
}
