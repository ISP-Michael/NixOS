hl.on(
  'hyprland.start',
  function()
    -- Даём systemd-user знать про Wayland-сессию: иначе Noctalia
    -- не видит logind, а порталы не стартуют.
    hl.exec_cmd(
      'systemctl --user import-environment XDG_SESSION_ID WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE; systemctl --user start hyprland-session.target'
    )
    hl.exec_cmd(
      'kitty',
      {
        workspace = 'special:magic'
      }
    )
  end
)
