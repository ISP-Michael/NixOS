-- Environment for the graphical session. Keyboard layout is handled by
-- settings/input.lua; no input-method variables are needed (fcitx is not
-- installed).
hl.env('XCURSOR_SIZE', '36')
hl.env('XCURSOR_THEME', 'Nordzy-cursors-white')
hl.env('HYPRCURSOR_SIZE', '36')
hl.env('HYPRCURSOR_THEME', 'Nordzy-hyprcursors-white')

-- Aquamarine: disable DRM buffer modifiers (workaround for this GPU).
hl.env('AQ_NO_MODIFIERS', '1')

-- Qt: KDE platform theme reads colours, fonts and icons from kdeglobals;
-- Breeze supplies native controls. The variables duplicate programs.qt so the
-- running Hyprland session picks them up after a reload without logging out.
hl.env('QT_QPA_PLATFORMTHEME', 'kde')
hl.env('QT_STYLE_OVERRIDE', 'breeze')
