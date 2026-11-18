-- File dialogs. Two rules are needed because Hyprland ANDs match fields:
-- "portal class OR native title" cannot be expressed in one match.
local P = require('profile')

local WIDTH = P.dialogs.width
local HEIGHT = P.dialogs.height

-- Host: FileChooser goes through the KDE portal (host/desktop/hyprland.nix).
-- ISO: through the GTK portal (iso/desktop.nix). The class list covers both,
-- including the wrapper names used by Nix.
local PORTAL_CLASS =
  '^(\\.?xdg-desktop-portal-(gtk|kde)(-wrapped)?|org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde)$'

hl.window_rule(
  {
    name = 'file-dialog-portal',
    match = {
      class = PORTAL_CLASS,
    },
    float = true,
    size = { WIDTH, HEIGHT },
    center = true,
  }
)

-- Applications that draw the dialog themselves keep their own class, so the
-- only reliable match is the title. The list is English because the session
-- locale is en_US.UTF-8; add localized titles if LANG changes.
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

local function escape_regex(text)
  return (text:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?%{%}|\\])', '\\%1'))
end

local function titles_regex(titles)
  local parts = {}
  for _, title in ipairs(titles) do
    parts[#parts + 1] = escape_regex(title)
  end

  -- Firefox appends " - Mozilla Firefox" to the page title.
  return '^(' .. table.concat(parts, '|') .. ')( - .*)?$'
end

hl.window_rule(
  {
    name = 'file-dialog-native',
    match = {
      title = titles_regex(NATIVE_TITLES),
    },
    float = true,
    size = { WIDTH, HEIGHT },
    center = true,
  }
)

-- kdialog is a native KDE dialog, not the portal and not an application
-- chooser. Neovide uses it for the project folder.
hl.window_rule(
  {
    name = 'kdialog-picker',
    match = {
      class = '^(org\\.kde\\.kdialog)$',
    },
    float = true,
    size = { WIDTH, HEIGHT },
    center = true,
  }
)
