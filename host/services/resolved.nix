{
  services = {
    resolved = {
      enable = true;
      settings = {
        Resolve = {
          # DoT «оппортунистический»: шифруем, если сервер умеет, иначе обычный DNS.
          # Строгий режим (yes) на плохих сетях валит весь DNS — не включать.
          DNSOverTLS = "opportunistic";
          # allow-downgrade: проверяем DNSSEC, но не ломаем резолв там, где он сломан
          DNSSEC = "allow-downgrade";
          Cache = "yes";
          DNS = [
            "1.1.1.1#cloudflare-dns.com"
            "9.9.9.9#dns.quad9.net"
            "8.8.8.8#dns.google"
          ];
          FallbackDNS = [
            "1.0.0.1#cloudflare-dns.com"
            "149.112.112.112#dns.quad9.net"
          ];
        };
      };
    };
  };
}
