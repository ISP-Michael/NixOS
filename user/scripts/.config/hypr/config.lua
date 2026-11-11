-- Опции Hyprland 0.56.2. Всё, что здесь не задано, берётся из дефолтов
-- сборки — полный список из 240+ опций лежит в стабах пакета:
-- /nix/store/*-hyprland-0.56.2/share/hypr/stubs/hl.meta.lua

hl.config(
  {
    general = {
      gaps_in = 0,
      gaps_out = 10,
      border_size = 0,
      col = {
        active_border = 'rgba(102, 102, 102, 0.06)',
        inactive_border = 'rgba(170, 170, 170, 0.02)',
      },
      resize_on_border = true,
      allow_tearing = true,

      -- Monocle: все окна во весь экран, переключение циклом
      -- (SUPER + , / SUPER + . или стрелки). До этого стоял scrolling,
      -- но он вёл себя ровно так же — column_width = 1.0 плюс
      -- fullscreen_on_one_column — только платил за геометрию лент и
      -- slide-анимацию между ними.
      layout = 'monocle',
    },

    decoration = {
      -- Блюр выключен. Параметры ниже инертны, пока enabled = false —
      -- это заготовка, а не работающая настройка. Включать на этой машине
      -- не стоит: несколько полноэкранных проходов при 82% VRAM и SCLK
      -- на 200 МГц. Если включать — начинать с passes = 1.
      blur = {
        enabled = false,
        size = 3,
        passes = 4,
        new_optimizations = true,
        ignore_opacity = true,
        popups = true
      },

      rounding = 10,
      active_opacity = 1.0,
      inactive_opacity = 1.0,

      -- Тени выключены. Что они стоили: квад тени = окно + 2*range
      -- по каждой стороне (src/render/decorations/CHyprDropShadowDecoration.cpp),
      -- а сам квад закрашивается фрагментным шейдером с pow() на каждом
      -- пикселе. При range = 100 окно 1886x1080 давало квад 2086x1280.
      --
      -- Отделять наложенные окна теперь почти нечем: border_size = 0,
      -- а округление (rounding = 10) даёт только скруглённые углы, но
      -- не контур. Плавающее окно поверх другого читается хуже, чем с
      -- тенью. Если начнёт мешать, самый дешёвый способ вернуть
      -- границу — рамка, она почти не стоит ничего:
      --     general = { border_size = 2,
      --                  col = { active_border = 'rgba(160,160,160,0.9)' } }
      -- Тот же результат, что давала тень, но без закрашивания
      -- квадра размером с окно на каждом кадре.
      shadow = {
        enabled = false,
        range = 28,
        render_power = 2,
        color = 0x99000000,
        offset = '0 0',
      },
    },

    input = {
      kb_layout = 'us,ru',
      kb_options = 'grp:win_space_toggle',
      follow_mouse = 1,
      sensitivity = 0,
      touchpad = {
        natural_scroll = true,
        drag_lock = 0,
        middle_button_emulation = true,
        clickfinger_behavior = true,

        -- Тап по тачпаду считается нажатием. Тачпад у ноутбука
        -- eliant 2204, и без этого по нему можно было только давить
        -- физически до упора.
        tap_to_click = true,

        -- Не скроллить текст, пока печатаешь. Полезно в терминале,
        -- где прокрутка двумя пальцами должна листать, а не листать
        -- назад по мере набора.
        disable_while_typing = true,
      },
    },

    gestures = {
      workspace_swipe_touch = true,
      workspace_swipe_direction_lock_threshold = 1,
    },

    misc = {
      force_default_wallpaper = 0,
      disable_hyprland_logo = true,

      -- Фон без обоев — чистый чёрный, а не серый по умолчанию.
      background_color = 0xFF000000,

      -- Мышь будит экран. Раньше этого не было: подумать было нечем,
      -- ноутбук просыпался только по кнопке питания.
      mouse_move_enables_dpms = true,
    },

    render = {
      new_render_scheduling = true,

      -- Прямой сканаут выключен: с ним у полноэкранных Wayland-окон
      -- (mpv, виртуалки) был чёрный экран. Раньше здесь стояла ссылка
      -- на апстрим issue #14843 — такого issue в hyprwm/hyprland нет
      -- (404, как и в hyprwm/aquamarine), поэтому ссылка убрана.
      -- При обновлении на 0.57 имеет смысл перепроверить: там много
      -- правок рендерера и fullscreen.
      direct_scanout = false,
    },

    cursor = {
      no_hardware_cursors = false,
      zoom_rigid = true,
      zoom_factor = 1.0,
    },
  }
)
