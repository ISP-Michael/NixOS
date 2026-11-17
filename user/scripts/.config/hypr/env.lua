-- Строки GTK_IM_MODULE / QT_IM_MODULE / XMODIFIERS = fcitx убраны.
-- fcitx в системе нет: `command -v fcitx` пусто. Раскладку и так
-- переключает сам Hyprland — kb_layout = 'us,ru' в config.lua плюс
-- kb_options = 'grp:win_space_toggle' (Super+Пробел). При этом
-- переменные указывали приложениям на модуль ввода, которого
-- никогда не появится.

hl.env('XCURSOR_SIZE', '36')
hl.env('XCURSOR_THEME', 'Nordzy-cursors-white')
hl.env('HYPRCURSOR_SIZE', '36')
hl.env('HYPRCURSOR_THEME', 'Nordzy-hyprcursors-white')
hl.env('AQ_NO_MODIFIERS', '1')

-- Qt: KDE platform theme читает цвета/шрифты/иконки из kdeglobals, а Breeze
-- даёт нативные контролы. Переменные дублируют NixOS programs.qt, чтобы
-- текущая сессия Hyprland подхватила их после reload без перезахода.
hl.env('QT_QPA_PLATFORMTHEME', 'kde')
hl.env('QT_STYLE_OVERRIDE', 'breeze')