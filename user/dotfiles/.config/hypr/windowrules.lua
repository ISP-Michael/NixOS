-- Правила окон для Hyprland 0.57.1.
--
-- Справка по match-свойствам (src/desktop/rule/Rule.cpp, MATCH_PROP_STRINGS):
--   class, title, initial_class, initial_title, float, tag, xwayland,
--   fullscreen, pin, focus, group, modal, workspace, content, xdg_tag,
--   namespace, fullscreen_state_internal, fullscreen_state_client
-- Плюс exec_token и exec_pid для правил, созданных из exec.
--
-- Все строковые match-свойства проверяются через RE2::FullMatch
-- (RegexMatchEngine.cpp) — то есть регулярка должна покрыть строку ЦЕЛИКОМ,
-- `^...$` не обязательны, но и не мешают.
--
-- Полезное:
--  * префикс `negative:` у регулярки —
--      match = { class = 'negative:^(firefox)$' }
--    совпадёт со всеми окнами, КРОМЕ firefox. Проверено на живой сессии.

-- ============================================================
-- ГЛОБАЛЬНЫЕ
-- ============================================================


-- Глушит запросы maximize у всех окон. F11 (fullscreen) не затронут.
hl.window_rule(
  {
    name = 'suppress-max',
    match = {
      class = '.*'
    },
    suppress_event = 'maximize',
  }
)

-- mpv/imv не должны открываться сразу во весь экран — иначе картинка
-- перекрывает всё при старте. Fullscreen по F11 потом работает.
hl.window_rule(
  {
    name = 'media-players',
    match = {
      class = '^(mpv|imv)$'
    },
    fullscreen = false,
  }
)

-- matplotlib под TkAgg ставит Tk(className="matplotlib"), а Tk на X11
-- отдаёт WM_CLASS с заглавной — проверено запуском: class=Matplotlib,
-- xwayland=true. Правило совпадает и работает.
hl.window_rule(
  {
    name = 'matplotlib-float',
    match = {
      class = '^(Matplotlib)$'
    },
    float = true,
  }
)

-- copyq: единственное его окно — это и есть настройки.
-- Положение: рабочая область начинается с x=10 и кончается на x=1866
-- (1920 минус gaps по 10 и 34 px бара), по вертикали 10..1070.
-- 1366 + 500 = 1866, 570 + 500 = 1070 — впритык к бару.
hl.window_rule(
  {
    name = 'copyq-settings',
    match = {
      class = '^(com.github.hluk.copyq)$'
    },
    float = true,
    size = {
      500,
      500
    },
    move  = {
      1366,
      570
    },
  }
)

-- Dolphin плавающий 1400x800. Правило раньше называлось dolphin-settings,
-- хотя ловит ВСЕ окна Dolphin по классу: у главного окна класс тот же.
-- Проверил — в monocle тайловое окно было бы во весь экран, а файловый
-- менеджер удобнее окном, поэтому поведение оставлено, но имя исправлено.
-- Если нужен только диалог настроек — добавить условие по title.
hl.window_rule(
  {
    name = 'dolphin-floating',
    match = {
      class = '^(org.kde.dolphin)$'
    },
    float = true,
    size = {
      1400,
      800
    },
  }
)

-- ============================================================
-- ДИАЛОГИ ВЫБОРА ФАЙЛОВ
-- ============================================================
-- Раньше это были пять отдельных правил (choose-files-telegram,
-- choose-files-firefox, choose-files-vlc, upload-file, xdg-portal),
-- каждое со своим набором размера и с разной логикой. Плюс у upload-file
-- стояла маска title = '.*([Ff]ile).*', которая из-за FullMatch ловила
-- ЛЮБОЕ окно со словом file: проверено — "Profile - Firefox" попадает,
-- потому что "file" входит в "Profile". Такое окно уехало бы во float
-- 1200x800 по центру.
--
-- Теперь один размер и одно положение заданы ОДИН раз, константами.

local FILE_DIALOG_W = 1200
local FILE_DIALOG_H = 800

-- Почему ниже две записи hl.window_rule, хотя блок один.
-- Hyprland склеивает поля match через AND: registerMatch кладёт каждое
-- свойство в отдельный движок, а match() требует совпадения всех сразу.
-- "класс портала ИЛИ заголовок приложения" одной записью не выражается.
-- Обе записи дают ОДИН И ТОТ ЖЕ результат — float + size + center, —
-- поэтому снаружи это один блок: размер и положение задаются здесь.

-- 1) Портал. Самый надёжный вариант: класс не зависит ни от приложения,
-- ни от языка, ни от того, какую задачу решает диалог (открыть, сохранить,
-- загрузить). Кто именно обслуживает FileChooser, задано в
-- /etc/xdg/xdg-desktop-portal/hyprland-portals.conf:
--     default=hyprland;gtk
--     org.freedesktop.impl.portal.FileChooser=kde
-- То есть ВСЕ файловые диалоги идут через KDE-портал. Прежнее правило
-- ловило только xdg-desktop-portal-gtk и для файлов не срабатывало
-- никогда. GTK-вариант оставлен на случай смены конфига порталов.
local PORTAL_CLASS =
  '^(\\.?xdg-desktop-portal-(gtk|kde)(-wrapped)?|org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde)$'

hl.window_rule(
  {
    name = 'file-dialog-portal',
    match = {
      class = PORTAL_CLASS
    },
    float = true,
    size = {
      FILE_DIALOG_W,
      FILE_DIALOG_H
    },
    center = true,
  }
)

-- 2) Приложения, которые рисуют диалог сами. У них класс совпадает с
-- классом самого приложения, поэтому отличить диалог можно только по
-- заголовку. Заголовок приходит от приложения (портал в
-- xdg-desktop-portal-gtk filechooser.c:490 просто передаёт arg_title
-- в gtk_file_chooser_dialog_new), поэтому список пополняется по мере
-- появления новых приложений. Локаль на машине en_US.UTF-8 — строки
-- английские. При смене LANG эти заголовки станут локализованными и
-- список придётся дополнять.
local NATIVE_TITLES = {
  'Open File', 'Open Files',
  'Open Folder', 'Open Directory',
  'Save File', 'Save Files',
  'Select File', 'Select Files',
  'Select Folder', 'Select Folders',
  'Choose File', 'Choose Files',
  'Upload File', 'Upload Files',
  'Add File', 'Add Files',
  'Import File', 'Import Files',
  'Select one or more files to open',
  'Blender File View',
}

-- Экранирование метасимволов RE2, чтобы заголовок можно было писать как есть.
local function re_escape(s)
  return (s:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?%{%}|\\])', '\\%1'))
end

local function titles_regex(list)
  local parts = {}
  for _, t in ipairs(list) do
    parts[#parts + 1] = re_escape(t)
  end
  -- Хвост " - <что угодно>" — Firefox дописывает к заголовку " - Mozilla Firefox".
  return '^(' .. table.concat(parts, '|') .. ')( - .*)?$'
end

hl.window_rule(
  {
    name = 'file-dialog-native',
    match = {
      title = titles_regex(NATIVE_TITLES)
    },
    float = true,
    size = {
      FILE_DIALOG_W,
      FILE_DIALOG_H
    },
    center = true,
  }
)

-- kdialog is a native KDE dialog, not the portal and not an application
-- file chooser.  Neovide calls it directly for the project folder, so its
-- class is org.kde.kdialog and the rules above do not match.  Without this
-- it is tiled like a normal window and drags Neovide into a relayout.
hl.window_rule(
  {
    name = 'kdialog-picker',
    match = {
      class = '^(org\\.kde\\.kdialog)$'
    },
    float = true,
    size = {
      FILE_DIALOG_W,
      FILE_DIALOG_H
    },
    center = true,
  }
)

-- ============================================================
-- ОСТАЛЬНОЕ
-- ============================================================

-- Всплывающее окно логина Figma в Firefox. Заголовок страницы —
-- "Login | Figma", Firefox дописывает " — Mozilla Firefox".
-- Раньше регулярка была '^(Login | Figma — Mozilla Firefox)$': скобка
-- открывала группу, а | работал как ИЛИ, поэтому правило совпадало либо
-- с "Login ", либо с " Figma — Mozilla Firefox" — то есть не с тем,
-- что задумано. Теперь | экранирован и понимается буквально.
hl.window_rule(
  {
    name = 'choose-login-firefox',
    match = {
      title = '^(Login \\| Figma — Mozilla Firefox)$'
    },
    float = true,
    center = true,
  }
)

-- Диалог выбора окна для захвата в OBS. Это не файловый диалог,
-- поэтому отдельно.
hl.window_rule(
  {
    name = 'obs-studio-select',
    match = {
      title = '^(Select what to share)$'
    },
    float = true,
  }
)

-- Плавное появление рамки выбора области у slurp. slurp рисует её через
-- zwlr_layer_shell_v1 с namespace "selection" (проверено strings).
hl.layer_rule(
  {
    name = 'screenshot-fade',
    match = {
      namespace = '^selection$'
    },
    animation = 'fade',
  }
)
