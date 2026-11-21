{
  config,
  ...
}:
{
  networking = {
    hostName = config.host.hostName;
    enableIPv6 = true;
    # AmneziaWG отдаёт IPv6 только ULA, а Fastly/Cachix имеют AAAA:
    # getaddrinfo по умолчанию может сначала идти в мёртвый IPv6 и
    # растягивать загрузку NAR до таймаутов. Предпочитаем IPv4, IPv6
    # остаётся как fallback.
    getaddrinfo = {
      precedence = {
        "::1/128" = 50;
        "::/0" = 40;
        "2002::/16" = 30;
        "::/96" = 20;
        "::ffff:0:0/96" = 100;
      };
    };
    # DNS задаётся в network/resolved.nix; второй список здесь только
    # сбивал бы с толку.
    networkmanager = {
      enable = true;
      wifi = {
        scanRandMacAddress = false;
      };
    };
  };
}
