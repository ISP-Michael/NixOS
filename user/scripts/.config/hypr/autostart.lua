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
    -- Строка 'opencode web' удалена. В opencode v2.0.15 команды web
    -- нет вообще, и она падала при каждом входе:
    --     $ opencode web
    --     Error: ENOENT: ... chdir '.../.config/hypr' -> 'web'
    -- opencode принимает 'web' за имя каталога. Служба и так уже
    -- поднята системой при загрузке:
    --     opencode serve --service   ->  0.0.0.0:49374
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
      'lutris',
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
    -- 'AmneziaVPN' заменено на 'amnezia-vpn'. Сам бинарник лежит в
    -- /opt/AmneziaVPN/bin/ и в PATH не попадает:
    --     $ command -v AmneziaVPN   ->  пусто
    -- Зато есть обёртка из NixOS-модуля host/services/amnezia-vpn-service.nix:
    --     /run/current-system/sw/bin/amnezia-vpn
    --         exec env NIX_LD_LIBRARY_PATH=… /opt/AmneziaVPN/bin/AmneziaVPN "$@"
    -- Desktop-файлов у приложения нет ни одного, так что запустить
    -- его можно только этой обёрткой.
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

