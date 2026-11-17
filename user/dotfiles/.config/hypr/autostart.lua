hl.on(
  'hyprland.start',
  function()
    -- Импорт XDG_SESSION_ID юзер-менеджеру systemd: без него юнит Noctalia
    -- не видит logind-сессию (локскрин, блокировка при засыпании), а у агента
    -- авторизации polkit не выполнилось бы условие WAYLAND_DISPLAY.
    -- Одной командой — чтобы импорт успел до старта target.
    hl.exec_cmd(
      'systemctl --user import-environment XDG_SESSION_ID WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE; systemctl --user start hyprland-session.target'
    )
    hl.exec_cmd(
      'copyq'
    )
    -- Нативный Rust-пикер: стартует скрытым, SUPER+W только переключает
    -- видимость через IPC. Так открытие мгновенное и без Qt.
    hl.exec_cmd(
      '/home/Michael/Data/Projects/WallpaperPicker/rs/run.sh daemon'
    )
    hl.exec_cmd(
      'openclaw gateway run'
    )
    hl.exec_cmd(
      'zen',
      {
        workspace = '2 silent'
      }
    )
    hl.exec_cmd(
      'Telegram',
      {
        workspace = '3 silent'
      }
    )
    -- Строка с ~/Projects/tg-ws-proxy/start.sh удалена: каталога нет,
    -- в ~/Projects остался только cuphead-binds, скрипт не существует
    -- нигде в домашнем каталоге. То есть команда падала при каждом входе.
    hl.exec_cmd(
      'obsidian',
      {
        workspace = '4 silent'
      }
    )
    hl.exec_cmd(
      'lutris',
      {
        workspace = '5 silent'
      }
    )
    hl.exec_cmd(
      'Throne',
      {
        workspace = '9 silent'
      }
    )
    hl.exec_cmd(
      'amnezia-vpn',
      {
        workspace = '9 silent'
      }
    )
    hl.exec_cmd(
      'kitty',
      {
        workspace = 'special:magic silent'
      }
    )
  end
)

