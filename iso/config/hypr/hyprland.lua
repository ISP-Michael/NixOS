-- Live-конфиг Hyprland: берём готовые модули из репозитория,
-- но не тянем autostart хоста (там Zen, Telegram, Obsidian, Lutris,
-- Throne и AmneziaVPN, которых на ISO может не быть).
package.path = "/etc/nixos/iso/config/hypr/?.lua;/etc/nixos/user/dotfiles/.config/hypr/?.lua;" .. package.path

require('variables')
require('env')
require('permissions')
require('config')
require('gestures')
require('animations')
require('binds')
require('windowrules')
require('autostart')

-- submaps.lua удалён вместе со старым screenshot-сабмапом; Print на
-- live сейчас не привязан. Если модуль вернут — добавить require('submaps').
