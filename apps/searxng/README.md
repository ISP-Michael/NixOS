# SearXNG

- Host: Docker-контейнер `searxng/searxng:latest` в
  `host/services/searxng`; обновление — `host/services/searxng/update.sh`
  (daily timer). Конфиг — `~/.config/searxng/settings.yml` (0600).
- ISO: `apps/searxng/package.nix` — upstream master pinned в Nix store,
  чтобы live-система работала без Docker и интернета.
- Проверка: `curl -sS 'http://127.0.0.1:8888/search?q=test&format=json'`.
- Версия ISO обновляется вручную: bump `rev`/`hash` в `package.nix`, затем
  пересобрать ISO.
