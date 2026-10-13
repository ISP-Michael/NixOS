---@diagnostic disable: undefined-field
---@module 'binds'
local M = require('variables')

-- Раньше было: 'pkill rofi || rofi -show drun' с release = true.
-- pkill на этой машине стоит 130-170 мс сам по себе (обходит весь /proc) —
-- почти столько же, сколько весь остальной запуск. Переключать открытие/закрытие
-- нечем: Esc закрывает rofi. Остался один процесс и одно нажатие.
-- -show-icons убран: в лаунчере нужны только названия, и в rofi 2.0 иконки
-- по умолчанию выключены. Тема — ~/.config/rofi/config.rasi (обычный каталог,
-- не флейк).
hl.bind(
  M.mainMod .. ' + R',
  hl.dsp.exec_cmd('rofi -show drun')
)

hl.bind(
  M.mainMod .. ' + SHIFT + R',
  hl.dsp.exec_cmd('rofi -show window')
)

hl.bind(
  M.mainMod .. ' + Q',
  hl.dsp.exec_cmd(M.terminal)
)

hl.bind(
  M.mainMod .. ' + E',
  hl.dsp.exec_cmd(M.fileManager)
)

-- Раньше на SUPER + P висело ДВА бинда сразу: hyprpicker и window.pseudo().
-- Одно нажатие запускало пипетку и заодно включало pseudo-режим.
hl.bind(
  M.mainMod .. ' + P',
  hl.dsp.exec_cmd('hyprpicker -a')
)

hl.bind(
  M.mainMod .. ' + C',
  hl.dsp.window.close()
)

-- ------------------------------------------------------------------
-- MONOCLE: переключение окон
-- ------------------------------------------------------------------
-- ВАЖНО. До перехода на monocle тут стояло hl.dsp.layout('togglesplit')
-- на SUPER + J, и оно было мёртвым ещё при scrolling:
--     $ hyprctl dispatch 'hl.dsp.layout("togglesplit")'
--     error: =[C]:-1: no such layoutmsg for scrolling
-- Scrolling принимает ровно 12 команд (move, colresize, fit, focus,
-- promote, expel, consume, consume_or_expel, swapcol, center,
-- inhibit_scroll, fit_into_view), togglesplit там нет — он есть только
-- у dwindle. В monocle команд всего две: cyclenext и cycleprev.
--
-- Тот же бинд SUPER + J удалён: ни в одном layout функции «разделить»
-- в monocle не существует, окно всегда во весь экран.
--
-- ЕЩЁ ВАЖНЕЕ. Стрелки в monocle тоже перестают работать. В
-- MonocleAlgorithm.cpp moveTargetInDirection() делает ровно одно —
-- ищет другой монитор в этом направлении, и если не находит, выходит
-- с noop. Монитор у тебя один (eDP-1), значит SUPER + стрелки были бы
-- полностью мёртвыми. Поэтому все четыре стрелки и обе точки
-- переключают окна циклом — иначе переключиться с клавиатуры
-- было бы нечем.
local function cycle(step)
  hl.dispatch(hl.dsp.layout(step > 0 and 'cyclenext' or 'cycleprev'))
end

hl.bind(M.mainMod .. ' + right', function() cycle(1) end)
hl.bind(M.mainMod .. ' + left', function() cycle(-1) end)
hl.bind(M.mainMod .. ' + down', function() cycle(1) end)
hl.bind(M.mainMod .. ' + up', function() cycle(-1) end)
hl.bind(M.mainMod .. ' + comma', function() cycle(1) end)
hl.bind(M.mainMod .. ' + period', function() cycle(-1) end)

hl.bind(
  M.mainMod .. ' + V',
  hl.dsp.window.float(
    {
      action = 'toggle'
    }
  )
)

hl.bind(
  M.mainMod .. ' + B',
  hl.dsp.exec_cmd('copyq toggle')
)

hl.bind(
  'F11',
  hl.dsp.window.fullscreen()
)

for i = 1, 10 do
  local key = i % 10
  hl.bind(
    M.mainMod .. ' + ' .. key,
    hl.dsp.focus(
      {
        workspace = i
      }
    )
  )
  hl.bind(
    M.mainMod .. ' + SHIFT + ' .. key,
    hl.dsp.window.move(
      {
        workspace = i
      }
    )
  )
end

hl.bind(
  M.alt .. ' + Tab',
  hl.dsp.window.bring_to_top()
)

hl.bind(
  M.alt .. ' + SHIFT + Tab',
  hl.dsp.window.bring_to_top(
    {
      prev = true
    }
  )
)

hl.bind(
  M.mainMod .. ' + S',
  hl.dsp.workspace.toggle_special(
    'magic'
  )
)

hl.bind(
  M.mainMod .. ' + SHIFT + S',
  hl.dsp.window.move(
    {
      workspace = 'special:magic'
    }
  )
)

hl.bind(
  M.mainMod .. ' + mouse_down',
  hl.dsp.focus(
    {
      workspace = 'e+1'
    }
  )
)

hl.bind(
  M.mainMod .. ' + mouse_up',
  hl.dsp.focus(
    {
      workspace = 'e-1'
    }
  )
)

hl.bind(
  'XF86MonBrightnessUp',
  hl.dsp.exec_cmd(
    'brightnessctl s +1%'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  'XF86MonBrightnessDown',
  hl.dsp.exec_cmd(
    'brightnessctl s 1%-'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  'XF86AudioRaiseVolume',
  hl.dsp.exec_cmd(
    'pamixer -i 5'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  'XF86AudioLowerVolume',
  hl.dsp.exec_cmd(
    'pamixer -d 5'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  'XF86AudioMute',
  hl.dsp.exec_cmd(
    'pamixer -t'
  ),
  {
    locked = true,
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + mouse:272',
  hl.dsp.window.drag(),
  {
    mouse = true
  }
)

hl.bind(
  M.mainMod .. ' + mouse:273',
  hl.dsp.window.resize(),
  {
    mouse = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + h',
  hl.dsp.window.resize(
    {
      x = -20,
      y = 0,
      relative = true
    }
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + l',
  hl.dsp.window.resize(
    {
      x = 20,
      y = 0,
      relative = true
    }
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + k',
  hl.dsp.window.resize(
    {
      x = 0,
      y = -20,
      relative = true
    }
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + j',
  hl.dsp.window.resize(
    {
      x = 0,
      y = 20,
      relative = true
    }
  ),
  {
    repeating = true
  }
)

hl.bind(
  M.mainMod .. ' + SHIFT + V',
  hl.dsp.window.pseudo()
)

hl.bind(
  M.mainMod .. ' + G',
  hl.dsp.group.toggle()
)

hl.bind(
  M.mainMod .. ' + CTRL + G',
  hl.dsp.window.move(
    {
      into_group = 'l'
    }
  )
)

hl.bind(
  M.mainMod .. ' + ALT + G',
  hl.dsp.window.move(
    {
      out_of_group = true
    }
  )
)

-- ОТКЛЮЧЕНО: /etc/nixos/dependencies/scripts/obs_screenshot.sh не существует
-- (каталог dependencies/scripts был пустым). Чтобы вернуть — положи скрипт
-- по этому пути или удали эти строки.
-- hl.bind(
--   M.mainMod .. ' + SHIFT + P',
--   hl.dsp.exec_cmd('/etc/nixos/dependencies/scripts/obs_screenshot.sh')
-- )

-- ------------------------------------------------------------------
-- ЗУМ КУРСОРА — целиком на Lua, внешний скрипт zoom.sh удалён
-- ------------------------------------------------------------------
-- Раньше здесь стоял exec_cmd('/etc/nixos/dependencies/scripts/zoom.sh up').
-- Скрипт делал две вещи, и обе стоили процесса:
--   1) hyprctl getoption cursor:zoom_factor — прочитать текущее (~35-40 мс)
--   2) hyprctl eval 'hl.config({...})' — записать новое (~35-40 мс)
-- то есть ~70-80 мс и два запуска клиента на одно нажатие, плюс
-- разбор вывода через awk.
--
-- `hyprctl keyword` в этой сборке не работает вообще (unknown request на
-- любую опцию), поэтому вариант «менять опцию напрямую» и не
-- рассматривался. А вот hl.config() из самого конфига — это прямая
-- запись, без процесса и без IPC: значение меняется мгновенно.
local zoom_index = 1

local function zoom(step)
  zoom_index = math.min(#M.zoomSteps, math.max(1, zoom_index + step))
  hl.config({ cursor = { zoom_factor = M.zoomSteps[zoom_index] } })
end

hl.bind(M.mainMod .. ' + equal', function() zoom(1) end)
hl.bind(M.mainMod .. ' + minus', function() zoom(-1) end)