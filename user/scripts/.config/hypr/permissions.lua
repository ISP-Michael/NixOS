-- Разрешения Hyprland 0.56.2 (новая система, ecosystem.enforce_permissions).
--
-- Что происходит. В DynamicPermissionManager.cpp проверка выглядит так:
--     static auto PPERM = CConfigValue<Config::INTEGER>("ecosystem:enforce_permissions");
--     if (*PPERM == 0)
--         return PERMISSION_RULE_ALLOW_MODE_ALLOW;
-- То есть при enforce_permissions = 0 (дефолт) разрешено ВСЁ и никаких
-- вопросов не бывает. Как только включаешь 1, для каждого клиента без
-- подходящего правила вызывается askForPermission() и возвращается
-- PENDING — всплывает диалог. Типов разрешений всего два:
-- PERMISSION_TYPE_SCREENCOPY (доступ к экрану) и PERMISSION_TYPE_PLUGIN
-- (загрузка плагинов), плюс проверка клавиатуры для инъекции ввода.
--
-- Правило hl.permission() получает РЕГУЛЯРКУ и проверяется через
-- RE2::FullMatch — то есть по ВСЕМУ пути целиком, а не по имени файла.
-- В примере из репозитория написано /usr/(bin|local/bin)/grim, но на
-- NixOS это бесполезно: бинарник лежит по пути в /nix/store, и его
-- полное имя содержит хеш сборки, который меняется при каждом
-- обновлении nixpkgs. Поэтому регекспы ниже заканчиваются на /bin/<имя>
-- и совпадают с любым хешем.
--
-- ВАЖНО: и enforce_permissions, и hl.permission применяются только при
-- перезапуске Hyprland — на лету, специально из соображений безопасности,
-- они не подхватываются. hyprctl reload config-only тут не поможет,
-- нужен полный перезапуск сессии.

hl.config({
  ecosystem = {
    enforce_permissions = true,
  },
})

-- Скриншоты. Кто угодно пишущий в wlr-screencopy.
hl.permission('/nix/store/[^/]*/bin/grim', 'screencopy', 'allow')
hl.permission('/nix/store/[^/]*/bin/slurp', 'screencopy', 'allow')
hl.permission('/nix/store/[^/]*/bin/hyprshot', 'screencopy', 'allow')
hl.permission('/nix/store/[^/]*/bin/satty', 'screencopy', 'allow')
hl.permission('/nix/store/[^/]*/bin/wl-copy', 'screencopy', 'allow')

-- Портал Hyprland: через него OBS, Discord, Telegram и браузер делают
-- захват экрана и демонстрацию окна. Если это не разрешить, screen
-- share перестанет работать и начнёт спрашивать.
hl.permission('/nix/store/[^/]*/bin/xdg-desktop-portal-hyprland', 'screencopy', 'allow')
hl.permission('/nix/store/[^/]*/libexec/xdg-desktop-portal-hyprland', 'screencopy', 'allow')

-- Менеджер плагинов.
hl.permission('/nix/store/[^/]*/bin/hyprpm', 'plugin', 'allow')

-- Откат, если что-то сломается: закомментируй enforce_permissions
-- выше (вернуть false) и перезапусти Hyprland.