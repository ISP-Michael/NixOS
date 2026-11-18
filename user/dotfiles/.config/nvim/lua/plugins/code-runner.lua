local P = require('pack')

P.register(
  'code_runner.nvim',
  function()
    P.load('code_runner.nvim')
    require('code_runner').setup(
      {
        filetype = {
          python = 'python3 -u',
          javascript = 'node',
          typescript = 'node',
          rust = 'cargo run',
          cpp = 'g++ -std=c++20 $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt',
          cs = 'dotnet run',
          go = 'go run',
        },
        mode = 'toggleterm',
      }
    )
  end
)

return {}
