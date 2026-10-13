---@module 'submaps'
local M = require('variables')

-- Скриншоты.
--
-- Раньше здесь стоял hyprshot, которого в системе нет вообще:
--     $ command -v hyprshot   ->   hyprshot not found
-- То есть весь сабмап был мёртвым: Print открывал его, а все пять
-- биндов внутри падали. hyprshot есть в nixpkgs (1.3.0), но grim и
-- slurp уже стояли в user/packages.nix — так что переписано на них.
--
-- Разница в синтаксисе:
--   hyprshot -m region   ->   grim -g "$(slurp)"   (slurp рисует рамку)
--   hyprshot -m output   ->   grim                 (весь экран целиком)
--   hyprshot -m window   ->   grim -g "X,Y WxH"    (берём из hyprctl)
--
-- Клавиша d — снимок с задержкой 3 секунды: окно успевает свернуться.
-- Раньше это был `bash -c 'sleep 1 && ...'`, то есть отдельный процесс
-- плюс ожидание. Теперь задержка делается через hl.timer — это таймер
-- внутри конфига, без шелла.
--
-- Клавиши z (зум/разметка) убраны: hyprshot -z открывал встроенный
-- редактор, а у grim такого нет. satty (0.22.0 в nixpkgs) делает
-- ровно то же и умеет вставляться в конвейер из grim.

hl.bind(
  'Print',
  hl.dsp.submap('screenshot')
)

hl.define_submap(
  'screenshot',
  function()
    -- r — область. slurp сначала рисует рамку, потом отдаёт координаты.
    hl.bind(
      'r',
      hl.dsp.exec_cmd(
        string.format(
          'mkdir -p %s && grim -g "$(slurp)" %s/$(date +%%F-%%H%%M%%S).png',
          M.shotDir,
          M.shotDir
        )
      )
    )

    -- o — весь экран целиком, без рамки выбора
    hl.bind(
      'o',
      hl.dsp.exec_cmd(
        string.format(
          'mkdir -p %s && grim %s/$(date +%%F-%%H%%M%%S).png',
          M.shotDir,
          M.shotDir
        )
      )
    )

    -- w — активное окно. Геометрию берём прямо из Lua API, без
    -- запуска hyprctl и без jq: у окна есть поля at {x,y} и size {w,h}.
    hl.bind('w', function()
      local win = hl.get_active_window()
      if not win then
        return
      end
      hl.dispatch(hl.dsp.exec_cmd(
        string.format(
          'mkdir -p %s && grim -g "%d,%d %dx%d" %s/$(date +%%F-%%H%%M%%S).png',
          M.shotDir,
          win.at[1],
          win.at[2],
          win.size[1],
          win.size[2],
          M.shotDir
        )
      ))
    end)

    -- d — область с задержкой 3 секунды. Сначала ждём, потом даём
    -- время выбрать рамку.
    hl.bind('d', function()
      hl.timer(
        function()
          hl.dispatch(hl.dsp.exec_cmd(
            string.format(
              'mkdir -p %s && grim -g "$(slurp)" %s/$(date +%%F-%%H%%M%%S).png',
              M.shotDir,
              M.shotDir
            )
          ))
        end,
        { timeout = 3000, type = 'oneshot' }
      )
    end)

    hl.bind(
      'escape',
      hl.dsp.submap('reset')
    )
  end
)