hl.on(
  'hyprland.start',
  function()
    local home_dir = os.getenv('HOME')
    local portals = {
      'xdg-desktop-portal.service',
      'xdg-desktop-portal-hyprland.service',
      'xdg-desktop-portal-gtk.service'
    }
    hl.exec_cmd(
      string.format(
        'systemctl --user start %s',
        table.concat(
          portals,
          ' '
        )
      )
    )
    hl.exec_cmd(
      'copyq'
    )
    hl.exec_cmd(
      'noctalia'
    )
    hl.exec_cmd(
      'opencode web'
    )
    hl.exec_cmd(
      'openclaw gateway run'
    )
    hl.exec_cmd(
      'neovide',
      {
        workspace = '1'
      }
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
      'mpv',
      {
        workspace = '5'
      }
    )
    --- hl.exec_cmd(
    ---   'qbittorrent',
    ---   {
    ---     workspace = '8'
    ---   }
    --- )
    hl.exec_cmd(
      'Throne',
      {
        workspace = '9'
      }
    )
    hl.exec_cmd(
      'AmneziaVPN',
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

