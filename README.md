# NixOS: MagicBook и live-ISO

Личный flake под ноутбук **HUAWEI BOHK-WAX9X** (AMD Vega 8, 6 ГБ ОЗУ).
Это не шаблон и не поддерживаемый дистрибутив: конфиг завязан на конкретное
железо, диск и пользователя.

Один flake на два режима:

- **`MagicBook`** — рабочая система: Hyprland, Home Manager, sops, Noctalia.
- **`iso-*`** — live-система с Hyprland и профилями приложений.

## Осторожно

- `host/identity.nix` задаёт `diskDevice = "/dev/nvme0n1"`. Установка через
  `disko` **сотрёт диск**. На другой машине сначала поменяй устройство и
  `host/hardware/*`.
- `secrets/secrets.yaml` зашифрован sops, приватных ключей в репозитории нет.
  Без ключа используй `MagicBookInstall` (временный пароль `nixos`) или добавь
  host-ключ, см. `docs/secrets.md`.

## Быстрый старт

```bash
git clone https://github.com/ISP-Michael/NixOS.git
cd NixOS

make check       # быстрая проверка: MagicBook + iso-custom
make ci          # полная: 7 конфигураций и 5 ISO
make switch      # собрать и активировать MagicBook (спросит sudo)
make build-iso   # собрать iso-custom в result-iso-custom
make status      # состояние manual-частей
```

`make check` не требует чистого дерева, `make ci` требует. Проверки и сборки
ограничены по памяти: `nix-daemon` — `CPUWeight=20`, `IOWeight=50`,
`MemoryHigh=3G`, а `nix eval` идёт в отдельной cgroup. На 6 ГБ это не даёт
им задушить композитор. Пока запущена игра, проверки и сборки отказываются
стартовать; осознанный обход — `ALLOW_GAMING=1`.

## Структура

| Каталог | Что внутри |
|---|---|
| `apps/` | Ручные и `/opt`-приложения: Amnezia, Happ, Throne, OpenCode, SearXNG. На хосте — официальные версии, на ISO — pinned. |
| `common/` | Переносимый слой: локаль, время, PipeWire, nix, appimage, nix-ld, zsh, bluetooth, MTP. |
| `host/` | Только MagicBook: identity, железо, диск, сеть, безопасность, сервисы, пользователи, Home Manager. |
| `iso/` | Live-система: профили, Hyprland, копия репозитория в `/etc/nixos`, установочные overrides. |
| `user/` | Home Manager: база, XDG, пакеты, программы, тема, dotfiles. |
| `vendor/` | Сторонний код со своей лицензией (`vendor/happ`, GPL-3.0). |
| `secrets/` | Зашифрованные sops-секреты и пример снимка. Приватные ключи сюда не кладутся. |
| `scripts/` | Проверки, деплой, пуш, статус, обслуживание. |
| `docs/` | Архитектура, решения, ISO, секреты, перенос, операции. |
| `assets/` | Картинки и обои; видео игнорируются git. |

## ISO

Профили — `iso-lite`, `iso` (work), `iso-custom`, `iso-media`, `iso-full`.
`custom` — основной: Hyprland, Firefox, LibreOffice, Telegram, KeePassXC,
OpenCode, AmneziaVPN и Happ. В меню только Firefox; Chromium — обёртка для
Playwright MCP.

Live-система работает без установки, но с неё же можно поставить систему:
репозиторий лежит в `/etc/nixos`. Steam, Blender, Docker и виртуалки в ISO
не входят. Запись на флешку и установка — `docs/iso.md`.

## Документация

- [`docs/architecture.md`](docs/architecture.md) — карта репозитория и границы слоёв.
- [`docs/ai.md`](docs/ai.md) — компактный контекст для ИИ-агента.
- [`docs/conventions.md`](docs/conventions.md) — стиль Nix и именование.
- [`docs/decisions.md`](docs/decisions.md) — что выключено и почему.
- [`docs/iso.md`](docs/iso.md) — профили, сборка, установка, live-поведение.
- [`docs/secrets.md`](docs/secrets.md) — sops, ключи, новые машины.
- [`docs/manual-apps.md`](docs/manual-apps.md) — `/opt`-приложения и проверка.
- [`docs/transfer.md`](docs/transfer.md) — перенос OpenCode/OpenClaw.
- [`docs/operations.md`](docs/operations.md) — проверки, деплой, git.
- [`docs/new-machine.md`](docs/new-machine.md) — новая машина.

## Скриншоты

![Fastfetch](docs/images/fastfetch.png)

![Neovide](docs/images/neovide.png)

## Лицензия

[Unlicense](LICENSE). `vendor/happ` — GPL-3.0, см. `vendor/happ/LICENSE`.
