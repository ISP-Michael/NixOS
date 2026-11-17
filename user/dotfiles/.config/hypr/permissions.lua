-- Разрешения Hyprland 0.56.2 (ecosystem.enforce_permissions).
--
-- Проверка в DynamicPermissionManager.cpp:
--     static auto PPERM = CConfigValue<Config::INTEGER>("ecosystem:enforce_permissions");
--     if (*PPERM == 0)
--         return PERMISSION_RULE_ALLOW_MODE_ALLOW;
-- При 0 (дефолт) разрешено всё и вопросов не бывает. При 1 любой клиент
-- без подходящего правила уходит в askForPermission() и возвращает
-- PENDING — всплывает диалог. Типов в enum пять:
-- SCREENCOPY, PLUGIN, KEYBOARD, CURSOR_POS, INPUT_CAPTURE.
--
-- ВАЖНО ПРО ПУТИ. hl.permission() получает регулярку и проверяет её через
-- RE2::FullMatch по ВСЕМУ пути бинарника. Путь берётся так
-- (MiscFunctions.cpp, binaryNameForPid):
--     std::format("/proc/{}/exe", pid) -> std::filesystem::canonical(...)
-- canonical разворачивает симлинки, поэтому правилом должен быть покрыт
-- РЕАЛЬНЫЙ путь. А в Nix половина пакетов — обёртки: рядом с бинарником
-- лежит .<имя>-wrapped, и /proc/exe указывает именно на него.
--
-- Проверено на живой сессии:
--   grim       -> .../bin/grim                        (без обёртки)
--   hyprpicker -> .../bin/hyprpicker                  (без обёртки)
--   hyprpm     -> .../bin/hyprpm                      (без обёртки)
--   noctalia   -> .../bin/.noctalia-wrapped           (ОБЁРТКА)
--   портал     -> .../libexec/.xdg-desktop-portal-hyprland-wrapped (ОБЁРТКА)
--
-- Поэтому ниже у этих двух путей стоят \.? и (-wrapped)? — иначе правило
-- не совпадает НИКОГДА. Раньше так и было: старые записи без точки и без
-- -wrapped не срабатывали, то есть screen share уходил в запрос.
--
-- Отдельно: `std::filesystem::canonical` ещё и разворачивает /etc/profiles,
-- так что писать /etc/profiles/per-user/... тоже бесполезно — нужен путь
-- в /nix/store с хешем, который меняется при обновлении. Отсюда [^/]*.
--
-- Применяется только при перезапуске Hyprland: на лету, специально из
-- соображений безопасности, правила не подхватываются.

hl.config(
  {
    ecosystem = {
      enforce_permissions = true,
    },
  }
)

-- Скриншоты и пипетка.
hl.permission('/nix/store/[^/]*/bin/grim', 'screencopy', 'allow')
hl.permission('/nix/store/[^/]*/bin/hyprpicker', 'screencopy', 'allow')

-- Локскрин Noctalia снимает экран для фона за окном входа.
hl.permission('/nix/store/[^/]*/bin/\\.?noctalia(-wrapped)?', 'screencopy', 'allow')

-- Портал Hyprland: через него OBS, Discord, Telegram и браузер делают
-- захват экрана и демонстрацию окна.
hl.permission('/nix/store/[^/]*/libexec/\\.?xdg-desktop-portal-hyprland(-wrapped)?', 'screencopy', 'allow')

-- Менеджер плагинов.
hl.permission('/nix/store/[^/]*/bin/hyprpm', 'plugin', 'allow')

-- Убрано как мёртвое (проверено strings по zwlr_screencopy_manager_v1):
--   slurp  — не снимает экран, только рисует рамку через layer-shell (0 упоминаний)
--   wl-copy — не снимает (0), плюс у него обёртка .wl-copy-wrapped
--   hyprshot, satty — в системе не установлены
--
-- Откат, если что-то сломается: поставить enforce_permissions = false
-- и перезапустить Hyprland.
