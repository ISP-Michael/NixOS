-- Import the Wayland/session identity into the user systemd manager and start
-- the target. Without XDG_SESSION_ID, Noctalia does not see the logind
-- session; without WAYLAND_DISPLAY, the polkit agent does not start.
return function()
  hl.exec_cmd(
    'systemctl --user import-environment XDG_SESSION_ID WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE; systemctl --user start hyprland-session.target'
  )
end
