# Горячие клавиши Hyprland

`mainMod = SUPER`, `alt = ALT`, `ctrl = CTRL` (`lib/defaults.lua`). Список
взят из `user/dotfiles/.config/hypr/binds/`; если правишь бинды — правь и
таблицу, иначе она начнёт врать.

## Приложения

| Клавиши | Действие |
|---|---|
| `SUPER + R` | меню приложений (rofi) |
| `SUPER + SHIFT + R` | переключатель окон (rofi) |
| `SUPER + Q` | терминал (kitty) |
| `SUPER + E` | файловый менеджер (Dolphin на хосте, Thunar на ISO) |
| `SUPER + B` | буфер обмена (CopyQ) |
| `SUPER + P` | пипетка цвета (hyprpicker) |
| `SUPER + W` | выбор обоев (только хост) |
| `SUPER + SHIFT + W` | закрыть выбор обоев |

## Окна

| Клавиши | Действие |
|---|---|
| `SUPER + C` | закрыть окно |
| `SUPER + ←/→/↑/↓`, `SUPER + ,/.` | переключить окно (monocle) |
| `ALT + Tab`, `ALT + SHIFT + Tab` | переключить окно вперёд/назад |
| `SUPER + V` | плавающее окно вкл/выкл |
| `SUPER + SHIFT + V` | pseudo-tiling |
| `F11` | полноэкранный режим |
| `SUPER + G` | группа окон вкл/выкл |
| `SUPER + CTRL + G` | добавить окно в группу |
| `SUPER + ALT + G` | вынуть окно из группы |
| `SUPER + SHIFT + h/j/k/l` | ресайз плавающего окна |
| `SUPER + ЛКМ` / `SUPER + ПКМ` | переместить / ресайзить окно |

## Столы

| Клавиши | Действие |
|---|---|
| `SUPER + 1…0` | перейти на стол 1…10 |
| `SUPER + SHIFT + 1…0` | переместить окно на стол 1…10 |
| `SUPER + S` | special-стол `magic` (scratch-терминал) |
| `SUPER + SHIFT + S` | переместить окно на `special:magic` |
| `SUPER + колесо` | следующий/предыдущий пустой стол |

## Прочее

| Клавиши | Действие |
|---|---|
| `SUPER + =` / `SUPER + -` | масштаб курсора (zoom) |
| `XF86MonBrightnessUp/Down` | яркость |
| `XF86AudioRaiseVolume/LowerVolume` | громкость |
| `XF86AudioMute` | mute |

Клавиши яркости и звука работают и на локскрине (`locked = true`), с
повтором при удержании. Слои keyd (Alt, цифры, навигация) — `docs/keyd.md`.
