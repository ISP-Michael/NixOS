{ ... }:
{
  # Cloudflare WARP. ВЫКЛЮЧЕН 05.11.2026: проверен и на домашнем Wi-Fi (MGTS),
  # и на мобильном хотспоте (TECNO). В обоих случаях MASQUE/QUIC-handshake
  # проходит, но туннель не поднимается: pmtu 1200, ретрансмиты, "quiche: idle
  # timeout expired", api_request Timeout. Маршрут по умолчанию и DNS при этом
  # уже переключены на WARP → падает весь трафик. WARP в РФ заблокирован,
  # библиотека nixpkgs 2026.8.2110.0 тут ни при чём.
  #
  # Не включать без повторной проверки: если Cloudflare поменяет протокол,
  # сначала `warp-cli --accept-tos connect`, затем сразу
  # `curl https://www.cloudflare.com/cdn-cgi/trace` (ждём warp=on) и откат,
  # если статус висит в Connecting.
  services.cloudflare-warp.enable = false;
}
