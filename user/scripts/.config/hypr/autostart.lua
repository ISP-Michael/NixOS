hl.on(
  'hyprland.start',
  function()
    local home_dir = os.getenv('HOME')
    -- Импорт XDG_SESSION_ID юзер-менеджеру systemd: без него юнит Noctalia
    -- не видит logind-сессию (локскрин, блокировка при засыпании).
    -- Одной командой — чтобы импорт успел до старта target.
    hl.exec_cmd(
      'systemctl --user import-environment XDG_SESSION_ID; systemctl --user start hyprland-session.target'
    )
    hl.exec_cmd(
      'copyq'
    )
    hl.exec_cmd(
      'openclaw gateway run'
    )
    hl.exec_cmd(
      'zen',
      {
        workspace = '2'
      }
    )
    hl.exec_cmd(
      'Telegram',
      {
        workspace = '3'
      }
    )
    hl.exec_cmd(
      home_dir .. '/Projects/tg-ws-proxy/start.sh'
    )
    hl.exec_cmd(
      'obsidian',
      {
        workspace = '4'
      }
    )
    hl.exec_cmd(
      'lutris',
      {
        workspace = '5'
      }
    )
    hl.exec_cmd(
      'Throne',
      {
        workspace = '9'
      }
    )
    hl.exec_cmd(
      'amnezia-vpn',
      {
        workspace = '9'
      }
    )
    hl.exec_cmd(
      'virt-manager -c qemu:///system --show-domain-console ubuntu25.10',
      {
        workspace = '10'
      }
    )
    hl.exec_cmd(
      'kitty',
      {
        workspace = 'special:magic'
      }
    )
  end
)

