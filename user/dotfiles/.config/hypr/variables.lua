local M = {}

M.fileManager = 'dolphin'
M.terminal = 'kitty'

M.mainMod = 'SUPER'
M.alt = 'ALT'

-- Шаги зума курсора. Раньше это был внешний скрипт zoom.sh, который
-- дергал `hyprctl getoption` + `hyprctl eval` — два запуска клиента
-- (~35-40 мс каждый) на одно нажатие. Теперь значение живёт прямо
-- в конфиге, переключение мгновенное и без процессов.
M.zoomSteps = { 1.0, 1.25, 1.5, 2.0, 2.5, 3.0 }

-- Папка для скриншотов. Раньше была вписана прямо в сабмап пять раз.
M.shotDir = '~/Images/screenshots'

return M