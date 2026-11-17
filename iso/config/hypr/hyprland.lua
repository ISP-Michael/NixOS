-- Live-конфиг Hyprland: берём готовые модули из репозитория,
-- но не тянем autostart хоста (там Zen, Telegram, Obsidian, Lutris,
-- Throne и AmneziaVPN, которых на ISO может не быть).
package.path = "/etc/nixos/iso/config/hypr/?.lua;/etc/nixos/user/scripts/.config/hypr/?.lua;" .. package.path

require('variables')
require('env')
require('permissions')
require('config')
require('gestures')
require('animations')
require('binds')
require('submaps')
require('windowrules')
require('autostart')
