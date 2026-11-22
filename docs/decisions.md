# Решения и выключенные вещи

Здесь — то, что удалено или выключено, и почему. Это не свалка кода:
история есть в git, а причина должна быть видна агенту.

## Удалено

| Что | Когда | Причина |
|---|---|---|
| `user/stylix/` + input `stylix` | 17.11.2026 | Заменено на `user/theme`: GTK/KDE/Qt/Noctalia вручную, Stylix больше не импортировался. |
| `user/services/mako.nix` | 17.11.2026 | Mako не установлен и не используется; уведомления — Noctalia. |
| `user/overlays.nix` | 17.11.2026 | Пустой файл, нигде не импортировался. |
| `host/services/kmscon.nix` | 17.11.2026 | Не импортировался, kmscon не активен. |
| `host/services/mihomo.nix` | 17.11.2026 | `enable = false`; конфиг `mihomo.yaml` остался в `host/services/` (gitignored), модуль не нужен. |
| `host/services/proxy.nix` | 17.11.2026 | Только `v2raya.enable = false`; не использовался. |
| `host/services/warp.nix` | 17.11.2026 | WARP проверен и не работает в РФ (MASQUE/QUIC timeout). Не включать без повторной проверки. |
| `host/services/zapret2.nix` | 17.11.2026 | Выключен с 14.11.2026: при поднятом AmneziaWG не нужен; `/opt/zapret2` остался для ручного запуска. |
| `host/services/amnezia-escape.nix` | 17.11.2026 | Обходной watcher маршрутов; не импортировался. Если Amnezia снова зациклит трафик — вернуть из истории. |
| `host/services/fstrim.nix` | 17.11.2026 | Слито в `host/hardware/disk.nix`: `services.fstrim.enable = false` (NixOS по умолчанию включает). |
| `host/soft/programs/clash.nix` | 17.11.2026 | Не импортировался; активные клиенты — Happ/Throne/Amnezia. |
| `host/soft/programs/amnezia-vpn.nix` | 17.11.2026 | Nix-модуль `programs.amnezia-vpn` выключен; используется `/opt` + `apps/amnezia/module.nix`. |
| `host/soft/programs/throne.nix` | 17.11.2026 | Nix-модуль `programs.throne` выключен; используется `/opt/Throne` + `apps/throne/module.nix`. |
| `host/scripts/` | 17.11.2026 | Не scripts, а activation-линкер `/etc/keyd`. Keyd переведён на `environment.etc` в `host/hardware/keyd/`. |
| `host/scripts/etc/openclaw/README.md` | 17.11.2026 | Пустой системный каталог; OpenClaw — пользовательский. |
| `config.lua`, `variables.lua`, `binds.lua`, `windowrules.lua` | 18.11.2026 | Плоский Hyprland-конфиг разложен по `settings/`, `binds/`, `rules/`, `profile.lua`; см. `docs/hyprland.md`. |
| `tmux` plugins `catppuccin/tmux`, `tmux-yank`, TPM | 18.11.2026 | Ни один не загружался: тема была inline, копирование — native OSC52, TPM не использовался. |
| zsh `.zcompdump`, `.zshrc.bak-*`, tracked `plugins*.zsh` | 18.11.2026 | Сгенерированное/устаревшее; compdump и история переехали в XDG state, static-бандлы antidote — в XDG cache. |
| nvim `queries/nix/injections.scm` | 18.11.2026 | Nix-injections отключены в `core/treesitter.lua`, файл был мёртвым. |
| nvim `plugins/deps.lua`, `plugins/run.lua`, `autocmds/*_template.lua` | 18.11.2026 | Разложены: `dependencies` + `vim-nix`, `toggleterm` + `code-runner` + `run`, один `autocmds/templates.lua`. |
| yazi `glow`, `hexyl`, `mediainfo`, `nbpreview`, `miller`, `rich-preview`, `wl-clipboard`, `full-border` | 19.11.2026 | Не подключены или не имеют бинарников; `piper`/`chmod`/SQLite/CBZ/video-grid/zoom/office оставлены и подключены. |
| input `hyprland` | 17.11.2026 | Не использовался: пакет берётся из nixpkgs (`pkgs.hyprland`). |

## Выключено намеренно

- **`services.fstrim.enable = false`** — btrfs смонтирован с `discard=async`;
  отдельный таймер не нужен и конкурирует за диск.
- **chrony `enableNTS = false`** — пулы `*.nixos.pool.ntp.org` не держат
  NTS-KE (TCP/4460); включение ломает синхронизацию.
- **SSH на live-ISO выключен** — пользователь `Michael` с пустым паролем,
  открытый 22-й порт не нужен. Включать вручную при необходимости.
- **Qt на ISO без `qt5ct`/`kvantum`** — на live нет Plasma и готовой темы;
  оставлен только `qt.enable = true` для плагинов. Пакеты `qt5ct`, `qt6ct`,
  `kvantum` больше не тянутся.
- **Flatpak** — модуль оставлен (`host/services/flatpak.nix`), пакетов нет.
  Новые Flatpak-приложения не добавлять без явной просьбы.
- **Happ на хосте** — ручной `/opt/happ` (`apps/happ/module.nix`), не
  `apps/happ/iso-module.nix`. На ISO — наоборот, Nix-модуль.
- **AmneziaVPN на хосте** — `/opt/AmneziaVPN` + `apps/amnezia/module.nix`;
  Nix-модуль `programs.amnezia-vpn` не используется.

## Известные особенности

- **tmux-тема разделена.** `themes/mocha.conf` — тёмный fallback;
  `themes/noctalia.conf` генерирует Noctalia, он в `.gitignore` и грузится
  последним. `statusline.conf` использует `@noctalia_*` для сессии, часов и
  вкладок, поэтому светлая палитра Noctalia даёт полностью светлый статусбар
  без катпучиновых сегментов.
- **tmux plugins** — `tmux-resurrect` и `tmux-continuum` лежат в
  `vendor/tmux/`, `~/.config/tmux/vendor` — симлинк. `tmux.service`
  генерирует continuum; его `ExecStop` обновлён на vendor-путь.
- **tmux backups** — 14 старых `.bak-*` перенесены в
  `~/.local/share/opencode/backups/tmux-2026-11-18`, не удалены.
- **zsh-конфиг разложен** — `.zshrc` только вход, `manifest.zsh` и `rc/`
  держат ответственности. `compinit` использует
  `~/.local/state/zsh/zcompdump`; zsh-completions грузится до compinit,
  fzf-tab — после compinit и до autosuggestions, syntax-highlighting
  последний. Antidote — в `vendor/zsh`; static-бандлы в
  `~/.cache/antidote/static`.
- **zsh-бэкапы и старые кэши** — `.zcompdump`, `.zshrc.bak-2026-11-16`,
  `~/.local/share/fzf-marks`, старые `compdump`/`starship-init.zsh`
  перенесены в `~/.local/share/opencode/backups/zsh-2026-11-18`.
- **nvim `o`/`O` с count** — старый lazy-конфиг требовал `core.O_o`; при
  переходе на `vim.pack` require потерялся. Возвращён как
  `core/repeat-o.lua`: `[count]o`/`[count]O` открывает count строк и
  оставляет insert на последней.
- **nvim-тема разложена** — `flat/theme/{ui,diagnostics,syntax,treesitter,
  lsp,plugins,terminal}.lua`; `flat/theme.lua` — совместимый вход. Удалены
  мёртвые Lazy/indent-guide группы и неиспользуемые ключи палитры.
  `core/completion.lua`, `core/lsp.lua`, `core/project.lua` пока не
  раздроблены: у них высокий риск, нужен отдельный headless-тест.
- **kitty `shell_integration no` был невалиден** — в 0.49 kitty писал
  `Invalid shell integration options: no, ignoring`. Заменено на
  `disabled`; конфиг разложен на `conf.d/`. `notify_on_cmd_finish` и
  полноценная интеграция оставлены как отдельный тест с zsh+tmux.
- **fastfetch 2.70** — добавлены battery/brightness/editor/localip/loadavg/
  processes/sound, `break` вместо пустого `custom`; presets/`--gen-config`/
  JSON/logo-протоколы описаны в `docs/fastfetch.md`.
- **yazi 26.9.1** — `ya pkg`/`package.toml` как managed-слой, vendored
  `chmod`/`piper`; подключены SQLite/CBZ/video-grid/zoom/office/piper,
  удалены нерабочие плагины. `theme.toml` остаётся одним файлом.
- **`submaps.lua` удалён.** ISO больше не делает `require('submaps')`;
  Print-сабмап со скриншотами не подключён. Вернуть файл можно из `dd6f314`.
  Вместе с ним из Hyprland-профиля удалён неиспользуемый `shotDir`.
- **`xdg.desktopEntries` сломан** в текущем Home Manager: опция `extraConfig`
  удалена, но модуль её выставляет. Для desktop-файлов используется
  `xdg.dataFile."applications/<name>.desktop"` (пример — Unciv).
- **`secrets/secrets.yaml` `lastmodified`** может оставаться старым:
  `sops updatekeys` обновляет получателей, но не перешифровывает файл.
  Получатели обновлены 17.11.2026; это важнее даты.
- **`~/Backups/opencode-restic/`** — 794 МБ; 18.11.2026 перенесён в
  `~/Backups/opencode-restic` и больше не лежит в репозитории.
- **`assets/videos/`** — 73 МБ, gitignored; в ISO не копируется.
- **`host/services/mihomo.yaml`** — 18.11.2026 перенесён в
  `~/Backups/removed-mihomo-2026-11-18/mihomo.yaml`; mihomo не используется.
- **`usque`** — 18.11.2026 остановлен и удалён из `/opt/usque` и
  `~/.config/systemd/user`; backup — `~/Backups/removed-usque-2026-11-18`.
  SearXNG работает без него, `extraInputRules 8088` удалено.
- **Noctalia** — 5.5.0 + fingerprint-патч. Тесты отключены, сборка идёт
  через `scripts/build-slow.sh` (один core, idle I/O, MemoryHigh 4G / Max 5G).
  Fallback — 5.4.1 из store; 5.5.0 собирается медленно, без кэша.
- **SearXNG на ISO** — upstream master pinned в `apps/searxng/package.nix`,
  не nixpkgs-снапшот. Host — Docker `searxng/searxng:latest`.
- **Дубли пакетов** — 18.11.2026 из `host/packages` убраны `flatpak`,
  `gpu-screen-recorder`, `pipewire`, `wireplumber`, `xdg-desktop-portal`
  (их добавляют модули), а также неиспользуемые `tlp` и `libfprint-tod`.
  Flatpak как сервис оставлен.
- **`opencode-update`** — юнит и скрипт перенесены в
  `user/dotfiles/.config/opencode/`; раньше жили только в `~/.local`.
- **Идентичность** — `host/identity.nix`: user/home/repoPath/hostName/diskDevice;
  HM получает `identity` через `extraSpecialArgs`. ISO — `iso.user`/`iso.hostName`.
- **`apps/happ`** — GPL-3.0 (производная от upstream `MrShitFox/happ-nixos`);
  версия/hash и локальные патчи описаны в `apps/happ/README.md`.
- **`user/theme/kde.nix`** и Noctalia `post_hook` пишут `kdeglobals`:
  это два вызова одного скрипта, не два разных владельца.
