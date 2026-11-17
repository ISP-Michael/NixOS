-- Опции Hyprland 0.57.1. Всё, что здесь не задано, берётся из дефолтов
-- сборки — полный список из 407 опций лежит в стабах пакета:
-- /nix/store/*-hyprland-0.57.1/share/hypr/stubs/hl.meta.lua

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

    -- Порог начала перетаскивания окна. По умолчанию 0 — окно начинает
    -- двигаться с первого пикселя сдвига, и на тачпаде обычный клик с
    -- лёгким дрожанием пальца уже тащит окно. 4 px — движение должно
    -- быть осознанным, случайные сдвиги отсекаются.
    -- (0.57: binds:drag_threshold)
    binds = {
      drag_threshold = 4,
    },

    decoration = {
      -- Блюр. В 0.57 вариантов одиннадцать: kawase, frost, ripple, drops,
      -- water, fluid_jar, prism, heat_shimmer, acrylic, aurora, haze.
      -- Варианты — это дополнительная обработка поверх обычного блюра, а
      -- анимированные (ripple, drops, water, fluid_jar, heat_shimmer,
      -- aurora) считаются ещё и каждый кадр. Поэтому базовый kawase,
      -- size 6, passes 1: размытие видно, лишних проходов нет.
      --
      -- Блюр проявляется только сквозь прозрачные пиксели, поэтому окна
      -- переведены на 0.95 / 0.90. В monocle видно ровно одно окно, так
      -- что полный экран размывается один раз, а не на каждое окно.
      blur = {
        enabled = false,
        variant = 'kawase',
        size = 6,
        passes = 1,
        new_optimizations = true,
        ignore_opacity = true,
        xray = false,
        noise = 0.02,
        contrast = 0.95,
        vibrancy = 0.2,
        popups = true,
        popups_ignorealpha = 0.2,
        special = false,
      },

      rounding = 10,
      active_opacity = 1,
      inactive_opacity = 1,

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

      -- Новые декорации 0.57 — glow (внутреннее свечение) и wobble
      -- (пружинная деформация окна при перетаскивании) — по умолчанию
      -- выключены, и на этой машине пусть такими остаются. Glow — ещё
      -- один шейдерный проход по краю окна, wobble — анимированная
      -- деформация сетки, которая на Vega 8 при SCLK 200 МГц дороже,
      -- чем даёт ощущений. Включать по одному и замерять.
    },

    input = {
      kb_layout = 'us,ru',
      kb_options = 'grp:win_space_toggle',
      follow_mouse = 1,
      sensitivity = 0,
      touchpad = {
        natural_scroll = true,
        -- Тачпад слишком резвый: один жест прокручивал сразу несколько
        -- экранов. 0.6 оставляет плавность, но убирает прыжки.
        scroll_factor = 0.6,
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

      -- Асинхронная отправка коммитов вывода (новое в 0.57). Позволяет
      -- композитору не ждать завершения предыдущего коммита, прежде чем
      -- готовить следующий кадр. Откат — убрать строку.
      async_commit = true,

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
