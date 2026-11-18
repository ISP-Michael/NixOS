{ pkgs }:
# Noctalia 5.4.1: Claim асинхронный, а release при разблокировке вызывается
# раньше, чем приходит ответ. Если ответ пришёл уже после unlock, устройство
# оставалось захваченным навсегда (sudo/локскрин получали "already claimed").
# Патч отпускает устройство в этом случае.
pkgs.noctalia.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./claim-release.patch
  ];
})
