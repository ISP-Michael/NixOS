-- Live-ISO entry point. Shared modules come from manifest.lua in the
-- repository's user/dotfiles tree; profile.lua and autostart.lua are resolved
-- from this directory first, so the host profile and host apps are not loaded.
package.path = "/etc/nixos/iso/config/hypr/?.lua;/etc/nixos/user/dotfiles/.config/hypr/?.lua;" .. package.path

require('manifest')
require('autostart')
