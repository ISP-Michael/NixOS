-- Shared composition for the host and the live ISO. This is the only list of
-- shared modules: system entries add their own monitors/autostart afterwards.
-- Keep the order: profile first, then declarative settings, rules, keybinds.
require('profile')

require('environment')
require('permissions')

require('settings.general')
require('settings.decoration')
require('settings.input')
require('settings.gestures')
require('settings.misc')
require('settings.render')
require('settings.cursor')
require('settings.animations')

require('rules.windows')
require('rules.file-dialogs')
require('rules.layers')

require('binds.apps')
require('binds.windows')
require('binds.workspaces')
require('binds.hardware-keys')
require('binds.zoom')
